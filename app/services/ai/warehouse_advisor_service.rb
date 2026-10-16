# frozen_string_literal: true

module Ai
  # Pain Point: Abhay K. (G2, 5/27/2026):
  #   "The standard edition restricts users to single cluster warehouse with
  #    default concurrency level of 8. This limitation forced us to upgrade to
  #    enterprise edition with multi-cluster support with big cut on the project budget."
  #
  # Solution: Analyzes usage trends and proactively recommends the RIGHT warehouse
  # size BEFORE the team is forced into an emergency upgrade that breaks the budget.
  #
  # Usage:
  #   result = Ai::WarehouseAdvisorService.call(warehouse)
  #   result[:current_size_adequate]   # true | false
  #   result[:recommended_size]        # "x-small" | "small" | "medium" | "large" | "x-large"
  #   result[:upgrade_urgency]         # "none" | "low" | "medium" | "high" | "immediate"
  #   result[:days_until_budget_crisis] # integer estimate
  #   result[:advice]                  # human-readable advice string
  #   result[:projected_monthly_cost]  # estimated monthly credit cost
  #   result[:source]                  # "gemini" | "rule_engine"
  class WarehouseAdvisorService
    SIZE_CREDIT_RATES = {
      "x-small" => 1,
      "small"   => 2,
      "medium"  => 4,
      "large"   => 8,
      "x-large" => 16
    }.freeze

    SIZE_ORDER = %w[x-small small medium large x-large].freeze

    def self.call(warehouse)
      new(warehouse).call
    end

    def initialize(warehouse)
      @warehouse = warehouse
    end

    def call
      metrics = compute_metrics
      gemini_result = fetch_gemini_advice(metrics)

      if gemini_result
        gemini_result.merge(
          metrics: metrics,
          source: "gemini"
        ).with_indifferent_access
      else
        rule_based_result(metrics)
      end
    end

    private

    def compute_metrics
      logs = @warehouse.credit_usage_logs.order(executed_at: :desc).limit(100)

      avg_credits_per_day = if logs.any?
        days_span = [(Time.current - logs.last.executed_at) / 1.day, 1].max
        logs.sum(:credits_spent).to_f / days_span
      else
        0.0
      end

      days_until_exhaustion = if avg_credits_per_day > 0
        (@warehouse.credits_remaining / avg_credits_per_day).round(1)
      else
        Float::INFINITY
      end

      quota_usage_trend = compute_trend(logs)
      projected_monthly = (avg_credits_per_day * 30).round

      {
        avg_credits_per_day: avg_credits_per_day.round(1),
        days_until_exhaustion: days_until_exhaustion.infinite? ? 9999 : days_until_exhaustion,
        usage_trend: quota_usage_trend,   # "accelerating" | "stable" | "decelerating"
        projected_monthly_cost: projected_monthly,
        total_log_count: logs.size,
        current_usage_pct: @warehouse.usage_pct,
        warning_threshold: @warehouse.warning_threshold_pct,
        throttled_events: @warehouse.status_events.where(to_status: "throttled").count,
        suspension_events: @warehouse.status_events.where(to_status: "suspended").count,
        recommended_quota: suggest_quota(avg_credits_per_day),
        recommended_size: suggest_size(avg_credits_per_day)
      }
    end

    def compute_trend(logs)
      return "stable" if logs.size < 6
      first_half  = logs.last(logs.size / 2).sum(&:credits_spent).to_f
      second_half = logs.first(logs.size / 2).sum(&:credits_spent).to_f
      return "stable" if first_half.zero?
      ratio = second_half / first_half
      ratio > 1.2 ? "accelerating" : (ratio < 0.8 ? "decelerating" : "stable")
    end

    def suggest_size(avg_per_day)
      return "x-small" if avg_per_day < 200
      return "small"   if avg_per_day < 500
      return "medium"  if avg_per_day < 1500
      return "large"   if avg_per_day < 4000
      "x-large"
    end

    def suggest_quota(avg_per_day)
      # Recommend quota = 35 days of current burn rate (some headroom)
      [ (avg_per_day * 35).round, @warehouse.credit_quota ].max
    end

    def fetch_gemini_advice(metrics)
      prompt = <<~PROMPT
        You are a FinOps AI warehouse sizing expert for Buzul cloud data warehouse platform.
        Your goal is to prevent teams from being surprised by forced upgrades or budget overruns
        (like the G2 reviewer who had to upgrade with "big cut on the project budget").

        WAREHOUSE PROFILE:
        - Name: #{@warehouse.name}
        - Current size: #{@warehouse.size.upcase}
        - Current status: #{@warehouse.status}
        - Department: #{@warehouse.department&.name}
        - Quota: #{@warehouse.credit_quota} credits/period
        - Credits used: #{@warehouse.credits_used} (#{@warehouse.usage_pct}%)

        USAGE METRICS:
        - Avg daily credit burn: #{metrics[:avg_credits_per_day]}
        - Projected monthly cost: #{metrics[:projected_monthly_cost]} credits
        - Usage trend: #{metrics[:usage_trend]}
        - Days until quota exhaustion at current rate: #{metrics[:days_until_exhaustion]}
        - Throttled events (historical): #{metrics[:throttled_events]}
        - Suspension events (historical): #{metrics[:suspension_events]}

        CURRENT RECOMMENDATION (rule engine):
        - Recommended size: #{metrics[:recommended_size].upcase}
        - Recommended quota: #{metrics[:recommended_quota]}

        Respond ONLY with this JSON (no markdown):
        {
          "current_size_adequate": true|false,
          "recommended_size": "x-small|small|medium|large|x-large",
          "upgrade_urgency": "none|low|medium|high|immediate",
          "days_until_budget_crisis": <integer>,
          "advice": "<Turkish actionable advice, max 200 chars>",
          "projected_monthly_cost": <integer>,
          "recommended_quota": <integer>,
          "key_risk": "<Turkish one-sentence risk statement>",
          "proactive_action": "<Turkish specific action to take this week>"
        }
      PROMPT

      Ai::GeminiClient.generate(prompt)
    rescue StandardError
      nil
    end

    def rule_based_result(metrics)
      current_idx   = SIZE_ORDER.index(@warehouse.size) || 0
      recommend_idx = SIZE_ORDER.index(metrics[:recommended_size]) || 0

      upgrade_needed  = recommend_idx > current_idx
      urgency         = compute_urgency(metrics)
      days_to_crisis  = metrics[:days_until_exhaustion].clamp(0, 9999)

      {
        current_size_adequate: !upgrade_needed,
        recommended_size: metrics[:recommended_size],
        upgrade_urgency: urgency,
        days_until_budget_crisis: days_to_crisis,
        advice: rule_advice(upgrade_needed, urgency, metrics),
        projected_monthly_cost: metrics[:projected_monthly_cost],
        recommended_quota: metrics[:recommended_quota],
        key_risk: key_risk_statement(metrics),
        proactive_action: proactive_action(upgrade_needed, urgency),
        metrics: metrics,
        source: "rule_engine"
      }.with_indifferent_access
    end

    def compute_urgency(metrics)
      return "immediate" if metrics[:days_until_exhaustion] < 3
      return "high"      if metrics[:days_until_exhaustion] < 7
      return "high"      if metrics[:throttled_events] >= 3
      return "medium"    if metrics[:days_until_exhaustion] < 14
      return "medium"    if metrics[:usage_trend] == "accelerating"
      return "low"       if metrics[:days_until_exhaustion] < 30
      "none"
    end

    def rule_advice(upgrade_needed, urgency, metrics)
      if urgency == "immediate"
        "Kritik: Kota #{metrics[:days_until_exhaustion].round} gün içinde dolacak! Acil bütçe onayı veya ambar boyutu küçültme gerekiyor."
      elsif upgrade_needed
        "Mevcut #{@warehouse.size.upcase} boyutu yetersiz. #{metrics[:recommended_size].upcase} boyutuna geçiş planlanmalı."
      elsif metrics[:usage_trend] == "accelerating"
        "Tüketim hızlanıyor. 30 gün içinde kota revizyonu önerilir."
      else
        "Mevcut boyut yeterli. Aylık #{metrics[:projected_monthly_cost]} kredi bütçelenebilir."
      end
    end

    def key_risk_statement(metrics)
      if metrics[:suspension_events] >= 2
        "Bu ambar daha önce #{metrics[:suspension_events]} kez askıya alındı — üretim sürekliliği risk altında."
      elsif metrics[:usage_trend] == "accelerating"
        "Hızlanan tüketim trendi, önümüzdeki ay bütçe patlaması yaşanabileceğine işaret ediyor."
      else
        "Mevcut tüketim hızında kota #{metrics[:days_until_exhaustion].to_i} gün sonra dolacak."
      end
    end

    def proactive_action(upgrade_needed, urgency)
      if urgency == "immediate"
        "Bugün: Departman yöneticisiyle acil kota artış toplantısı yapın."
      elsif urgency == "high"
        "Bu hafta: Bütçe onay sürecini başlatın; boyut yükseltme için finansman talep edin."
      elsif upgrade_needed
        "Bu ay: Kapasite planlama toplantısı düzenleyin; yükseltme maliyetini analiz edin."
      else
        "Aylık: Tüketim trendini izleyin; büyüme planına göre kota güncelleyin."
      end
    end
  end
end
