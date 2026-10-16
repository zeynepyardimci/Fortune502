# frozen_string_literal: true

# Serves the unified AI Insights panel for a given warehouse.
# Routes:
#   GET  /warehouses/:warehouse_id/ai_insights          → show (full panel)
#   POST /warehouses/:warehouse_id/ai_insights/predict  → predict cost (AJAX-friendly)
class AiInsightsController < ApplicationController
  before_action :set_warehouse

  # GET /warehouses/:warehouse_id/ai_insights
  # Runs all three AI services and renders the full AI dashboard.
  def show
    @cost_prediction  = Ai::CostPredictorService.call(
      @warehouse,
      query_signature:   params[:query_signature].presence || "SAMPLE_QUERY_ANALYSIS",
      credits_requested: params[:credits_requested].presence&.to_f || 0
    )
    @query_insights   = Ai::QueryOptimizerService.call(@warehouse)
    @advisor_report   = Ai::WarehouseAdvisorService.call(@warehouse)
  end

  # POST /warehouses/:warehouse_id/ai_insights/predict
  # Called from the warehouse show page before submitting a query.
  # Returns JSON: { risk_level:, recommendation:, optimization_tip:, should_block: }
  def predict
    result = Ai::CostPredictorService.call(
      @warehouse,
      query_signature:   params[:query_signature].to_s,
      credits_requested: params[:credits_requested].to_f
    )
    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to warehouse_ai_insights_path(@warehouse, query_signature: params[:query_signature], credits_requested: params[:credits_requested]) }
    end
  end

  private

  def set_warehouse
    @warehouse = Warehouse.find(params[:warehouse_id])
  end
end
