class CreditUsageLogsController < ApplicationController
  def create
    @warehouse = Warehouse.find(params[:warehouse_id])

    credits = params[:credits_spent].to_f
    query_sig = params[:query_signature].presence || "SELECT * FROM analytics_events_#{Time.current.to_i}"

    if credits <= 0
      redirect_to @warehouse, alert: "Harcanan kredi miktarı sıfırdan büyük olmalıdır."
      return
    end

    if @warehouse.suspended?
      redirect_to @warehouse, alert: "Bu ambar askıya alınmış durumda (suspended). Yeni sorgu ve kredi harcaması kabul edemez."
      return
    end

    ActiveRecord::Base.transaction do
      @warehouse.credit_usage_logs.create!(
        credits_spent: credits,
        query_signature: query_sig,
        executed_at: Time.current
      )

      # Recalculate usage and trigger status transition if quota thresholds reached
      Finops::QuotaCalculatorService.recalculate!(@warehouse)
    end

    redirect_to @warehouse, notice: "#{credits} kredi harcaması kaydedildi. Güncel durum: #{@warehouse.status.upcase} (Kullanım: %#{@warehouse.usage_pct})"
  end
end
