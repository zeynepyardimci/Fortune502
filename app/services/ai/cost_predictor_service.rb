# frozen_string_literal: true

module Ai
  # Pain Point: Harshil A. (G2, 6/1/2026):
  #   "costs can sometimes be difficult to predict... cost management requires
  #    ongoing attention and planning."
  #
  # Solution: Before a warehouse runs a new query batch, this service predicts
  # the likely credit consumption and warns if it would push the warehouse into
  # warning or throttled territory.
  #
  # Usage:
  #   result = Ai::CostPredictorService.call(warehouse, query_signature:, credits_requested:)
  #   result[:risk_level]        # "low" | "medium" | "high" | "critical"
  #   result[:predicted_total]   # estimated credits_used after this query
  #   result[:recommendation]    # human-readable recommendation string
  #   result[:should_block]      # true if query should be blocked proactively
  #   result[:source]            # "gemini" | "rule_engine"
  class CostPredictorService
    RISK_THRESHOLDS = { low: 60, medium: 80, high: 95, critical: 100 }.freeze

    def self.call(warehouse, query_signature:, credits_requested:)
      new(warehouse, query_signature:, credits_requested:).call
    end

    def initialize(warehouse, query_signature:, credits_requested:)
      @warehouse         = warehouse
      @query_signature   = query_signature.to_s
      @credits_requested = credits_requested.to_f
    end

    def call
      predicted_total = @warehouse.credits_used + @credits_requested
      new_pct         = (predicted_total / @warehouse.credit_quota.to_f * 100).round(1)
      risk            = compute_risk(new_pct)

      gemini_result = fetch_gemini_insight(predicted_total, new_pct, risk)

      if gemini_result
        gemini_result.merge(
          predicted_total: predicted_total,
          new_usage_pct: new_pct,
          source: "gemini"
        ).with_indifferent_access
      else
        rule_based_result(predicted_total, new_pct, risk)
      end
    end

    private

    def fetch_gemini_insight(predicted_total, new_pct, risk)
      prompt = <<~PROMPT
        You are a FinOps AI assistant for Buzul, a cloud data warehouse cost management platform.

        Analyze this warehouse credit consumption scenario and respond with a JSON object only.

        WAREHOUSE STATE:
        - Name: #{@warehouse.name}
        - Current status: #{@warehouse.status}
        - Credits used: #{@warehouse.credits_used} / #{@warehouse.credit_quota} (#{@warehouse.usage_pct}% used)
        - Warning threshold: #{@warehouse.warning_threshold_pct}%
        - Department: #{@warehouse.department&.name}

        REQUESTED QUERY:
        - Signature: #{@query_signature}
        - Credits requested: #{@credits_requested}
        - Predicted total after query: #{predicted_total} credits (#{new_pct}% of quota)
        - Computed risk level: #{risk}

        RECENT PATTERNS (last 5 queries):
        #{recent_query_summary}

        Respond ONLY with this JSON structure (no markdown, no explanation):
        {
          "risk_level": "low|medium|high|critical",
          "recommendation": "<one concise sentence in Turkish, max 120 chars>",
          "optimization_tip": "<specific optimization suggestion for this query pattern in Turkish, max 160 chars>",
          "should_block": false,
          "estimated_daily_burn_rate": <number>
        }
      PROMPT

      Ai::GeminiClient.generate(prompt)
    rescue StandardError
      nil
    end

    def rule_based_result(predicted_total, new_pct, risk)
      {
        risk_level: risk,
        predicted_total: predicted_total,
        new_usage_pct: new_pct,
        recommendation: rule_recommendation(risk, new_pct),
        optimization_tip: optimization_tip_for(@query_signature),
        should_block: risk == "critical" && @warehouse.throttled?,
        estimated_daily_burn_rate: estimate_daily_burn,
        source: "rule_engine"
      }.with_indifferent_access
    end

    def compute_risk(pct)
      return "critical" if pct >= RISK_THRESHOLDS[:critical]
      return "high"     if pct >= RISK_THRESHOLDS[:high]
      return "medium"   if pct >= RISK_THRESHOLDS[:medium]
      "low"
    end

    def rule_recommendation(risk, pct)
      case risk
      when "critical" then "Kota doldu! Bu sorgu çalıştırılırsa ambar throttled durumuna geçecek."
      when "high"     then "Dikkat: %#{pct.round} kullanım — ambar kritik eşiğe yaklaşıyor."
      when "medium"   then "Uyarı eşiğine yaklaşılıyor (%#{pct.round}). Sorgu boyutunu küçültmeyi değerlendirin."
      else                 "Düşük risk. Sorgu güvenle çalıştırılabilir (%#{pct.round} kullanım)."
      end
    end

    def optimization_tip_for(sig)
      sig_up = sig.upcase
      if sig_up.include?("FULL_SCAN") || sig_up.include?("DEEP") || sig_up.include?("UNOPTIMIZED")
        "WHERE koşulu ve partition filtresi ekleyerek tam tablo taramasından kaçının."
      elsif sig_up.include?("ETL") || sig_up.include?("BATCH")
        "ETL işlerini mesai dışı saatlerde (gece yarısı) çalıştırmayı değerlendirin."
      elsif sig_up.include?("ML") || sig_up.include?("LEARNING")
        "ML eğitimini ayrı bir warehouse'a taşıyın; üretim kotasını koruyun."
      else
        "Sorgu planını EXPLAIN ile inceleyin; gereksiz JOIN'leri ve sub-query'leri kaldırın."
      end
    end

    def estimate_daily_burn
      return 0 if @warehouse.credit_usage_logs.empty?
      recent = @warehouse.credit_usage_logs.order(executed_at: :desc).limit(20)
      return 0 if recent.empty?
      avg_per_query = recent.sum(:credits_spent).to_f / recent.size
      # rough estimate: assume similar query frequency throughout the day
      (avg_per_query * 24).round(1)
    end

    def recent_query_summary
      logs = @warehouse.credit_usage_logs.order(executed_at: :desc).limit(5)
      return "No previous queries." if logs.empty?
      logs.map { |l| "  - #{l.query_signature}: #{l.credits_spent} credits" }.join("\n")
    end
  end
end
