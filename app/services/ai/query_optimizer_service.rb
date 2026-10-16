# frozen_string_literal: true

module Ai
  # Pain Point: Pankaj K. (G2, 5/28/2026):
  #   "those inefficiencies may translate into higher compute costs, which then
  #    impacts overall ROI."
  #
  # Solution: Analyzes the warehouse's recent query patterns and generates
  # concrete SQL/pipeline optimization recommendations to reduce credit waste.
  #
  # Usage:
  #   result = Ai::QueryOptimizerService.call(warehouse)
  #   result[:issues]          # Array of detected anti-patterns
  #   result[:recommendations] # Array of actionable fixes
  #   result[:wasted_credits]  # Estimated credits wasted on bad patterns
  #   result[:savings_pct]     # Estimated savings if optimizations applied
  #   result[:source]          # "gemini" | "rule_engine"
  class QueryOptimizerService
    # Patterns that indicate inefficient queries
    ANTI_PATTERNS = {
      full_scan:    /FULL[_\s]SCAN|UNOPTIMIZED|NO[_\s]FILTER/i,
      deep_run:     /DEEP[_\s]LEARNING|ML[_\s]TRAIN/i,
      heavy_etl:    /HEAVY[_\s]ETL|LARGE[_\s]BATCH/i,
      adhoc_large:  /ADHOC.*\d{4,}|LARGE.*ADHOC/i,
      no_partition: /ALL[_\s]DATA|FULL[_\s]HISTORY/i
    }.freeze

    def self.call(warehouse)
      new(warehouse).call
    end

    def initialize(warehouse)
      @warehouse = warehouse
    end

    def call
      recent_logs = @warehouse.credit_usage_logs.order(executed_at: :desc).limit(50)
      return empty_result if recent_logs.empty?

      detected_issues  = detect_anti_patterns(recent_logs)
      wasted_credits   = estimate_wasted_credits(recent_logs, detected_issues)
      savings_pct      = estimate_savings(wasted_credits, recent_logs)

      gemini_result = fetch_gemini_analysis(recent_logs, detected_issues, wasted_credits)

      if gemini_result
        gemini_result.merge(
          wasted_credits: wasted_credits,
          savings_pct: savings_pct,
          detected_issue_count: detected_issues.size,
          source: "gemini"
        ).with_indifferent_access
      else
        rule_based_result(detected_issues, wasted_credits, savings_pct)
      end
    end

    private

    def fetch_gemini_analysis(logs, issues, wasted)
      prompt = <<~PROMPT
        You are a FinOps AI SQL optimization expert for Buzul cloud data warehouse platform.

        Analyze this warehouse's query patterns and respond with a JSON object ONLY.

        WAREHOUSE: #{@warehouse.name} (#{@warehouse.size.upcase} tier)
        DEPARTMENT: #{@warehouse.department&.name}
        TOTAL CREDITS USED: #{@warehouse.credits_used} / #{@warehouse.credit_quota}

        RECENT QUERY SIGNATURES (last #{logs.size}, sorted by credits desc):
        #{logs.sort_by { |l| -l.credits_spent }.first(10).map { |l| "  - #{l.query_signature}: #{l.credits_spent} credits at #{l.executed_at.strftime('%H:%M')}" }.join("\n")}

        DETECTED ANTI-PATTERNS: #{issues.map { |i| i[:type] }.join(", ").presence || "none"}
        ESTIMATED WASTED CREDITS: #{wasted}

        Respond ONLY with this JSON (no markdown):
        {
          "issues": [
            {"type": "anti-pattern name", "description": "<Turkish explanation max 100 chars>", "severity": "low|medium|high"}
          ],
          "recommendations": [
            {"title": "<Turkish title>", "action": "<Turkish concrete action max 140 chars>", "credit_savings": <number>}
          ],
          "executive_summary": "<Turkish 2-sentence summary for management>",
          "top_offender_query": "<query signature with highest waste>",
          "optimization_score": <0-100 integer, 100=fully optimized>
        }
      PROMPT

      Ai::GeminiClient.generate(prompt)
    rescue StandardError
      nil
    end

    def detect_anti_patterns(logs)
      issues = []
      ANTI_PATTERNS.each do |type, pattern|
        offending = logs.select { |l| l.query_signature.match?(pattern) }
        next if offending.empty?

        total_credits = offending.sum(&:credits_spent)
        issues << {
          type: type,
          offending_queries: offending.map(&:query_signature).uniq.first(3),
          total_credits: total_credits,
          description: anti_pattern_description(type),
          severity: severity_for(total_credits, logs)
        }
      end
      issues
    end

    def estimate_wasted_credits(logs, issues)
      waste_rates = {
        full_scan:    0.60,  # 60% of credits wasted on full scans
        deep_run:     0.40,
        heavy_etl:    0.30,
        adhoc_large:  0.50,
        no_partition: 0.55
      }
      issues.sum do |issue|
        (issue[:total_credits] * (waste_rates[issue[:type]] || 0.35)).round
      end
    end

    def estimate_savings(wasted, logs)
      total = logs.sum(&:credits_spent).to_f
      return 0 if total.zero?
      [(wasted / total * 100).round(1), 80].min
    end

    def rule_based_result(issues, wasted, savings_pct)
      recommendations = issues.flat_map { |i| rule_recommendations_for(i) }
      {
        issues: issues,
        recommendations: recommendations,
        executive_summary: rule_summary(issues, wasted),
        top_offender_query: issues.max_by { |i| i[:total_credits] }&.dig(:offending_queries, 0) || "—",
        optimization_score: [ 100 - savings_pct.to_i, 0 ].max,
        wasted_credits: wasted,
        savings_pct: savings_pct,
        detected_issue_count: issues.size,
        source: "rule_engine"
      }.with_indifferent_access
    end

    def rule_recommendations_for(issue)
      case issue[:type]
      when :full_scan
        [ { title: "Partition Filtresi Ekle", action: "WHERE koşuluna tarih/partition filtresi ekleyerek tam tablo taramasını önleyin.", credit_savings: (issue[:total_credits] * 0.55).round } ]
      when :deep_run
        [ { title: "ML İşini Ayrı Ambara Taşı", action: "Model eğitimini ayrı bir ML warehouse'una taşıyın; üretim kotasını koruyun.", credit_savings: (issue[:total_credits] * 0.35).round } ]
      when :heavy_etl
        [ { title: "ETL Saatini Optimize Et", action: "Ağır ETL'leri mesai dışı (01:00-05:00) saatlere taşıyın; gündüz kotasını koruyun.", credit_savings: (issue[:total_credits] * 0.25).round } ]
      when :adhoc_large
        [ { title: "Adhoc Sorgu Limitini Belirle", action: "Büyük adhoc sorgular için LIMIT ve tarih aralığı zorunlu kılın.", credit_savings: (issue[:total_credits] * 0.45).round } ]
      when :no_partition
        [ { title: "Partition Stratejisi Uygula", action: "Tablo partition'larını tarih/bölge bazında tanımlayın; tüm geçmiş taramalarını önleyin.", credit_savings: (issue[:total_credits] * 0.50).round } ]
      else
        []
      end
    end

    def rule_summary(issues, wasted)
      if issues.empty?
        "Sorgu kalıpları makul görünüyor. Önemli bir optimizasyon fırsatı tespit edilmedi."
      else
        "#{issues.size} anti-pattern tespit edildi. Tahminen #{wasted} kredi gereksiz harcanıyor. Öneriler uygulanırsa bütçede %#{(wasted.to_f / [@warehouse.credits_used, 1].max * 100).round} tasarruf mümkün."
      end
    end

    def anti_pattern_description(type)
      {
        full_scan: "Partition filtresi olmayan tam tablo taraması",
        deep_run: "Yüksek kaynak tüketen ML model eğitimi",
        heavy_etl: "Mesai içi saatlerde ağır toplu veri işleme",
        adhoc_large: "Limitsiz büyük adhoc sorgu",
        no_partition: "Tüm geçmiş veriyi tarayan filtresiz sorgu"
      }[type] || "Bilinmeyen anti-pattern"
    end

    def severity_for(credits, logs)
      total = logs.sum(&:credits_spent).to_f
      return "low" if total.zero?
      pct = credits / total * 100
      pct >= 50 ? "high" : (pct >= 25 ? "medium" : "low")
    end

    def empty_result
      {
        issues: [], recommendations: [],
        executive_summary: "Analiz için yeterli sorgu geçmişi bulunamadı.",
        top_offender_query: "—", optimization_score: 100,
        wasted_credits: 0, savings_pct: 0,
        detected_issue_count: 0, source: "rule_engine"
      }.with_indifferent_access
    end
  end
end
