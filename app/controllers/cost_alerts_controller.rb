class CostAlertsController < ApplicationController
  def index
    @unacknowledged_alerts = CostAlert.includes(:warehouse).where(acknowledged: false).order(created_at: :desc)
    @acknowledged_alerts = CostAlert.includes(:warehouse, :acknowledged_by).where(acknowledged: true).order(created_at: :desc).limit(20)
  end

  def update
    @alert = CostAlert.find(params[:id])
    @alert.update!(acknowledged: true)

    redirect_to cost_alerts_path, notice: "Uyarı onaylandı / arşivlendi."
  end
end
