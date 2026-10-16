class WarehousesController < ApplicationController
  before_action :set_warehouse, only: [:show, :edit, :update, :destroy, :transition, :approve_sla]

  def index
    @warehouses = Warehouse.includes(:department).order(:name)
  end

  def show
    @usage_logs = @warehouse.credit_usage_logs.order(executed_at: :desc).limit(20)
    @status_events = @warehouse.status_events.includes(:triggered_by).order(created_at: :desc).limit(20)
    @alerts = @warehouse.cost_alerts.order(created_at: :desc).limit(10)
  end

  def new
    @warehouse = Warehouse.new(credit_quota: 1000, warning_threshold_pct: 80, status: "active", size: "small")
    @departments = Department.order(:name)
  end

  def create
    @warehouse = Warehouse.new(warehouse_params)
    @departments = Department.order(:name)

    if @warehouse.save
      redirect_to @warehouse, notice: "Ambar başarıyla oluşturuldu."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @departments = Department.order(:name)
  end

  def update
    if @warehouse.update(warehouse_params)
      redirect_to @warehouse, notice: "Ambar güncellendi."
    else
      @departments = Department.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @warehouse.destroy
    redirect_to warehouses_path, notice: "Ambar başarıyla silindi."
  end

  def transition
    target_status = params[:status]
    reason = params[:reason] || "Manuel kullanıcı aksiyonu"

    begin
      Warehouses::StatusTransitionService.transition!(
        warehouse: @warehouse,
        to_status: target_status,
        reason: reason
      )
      redirect_to @warehouse, notice: "Durum '#{target_status}' olarak güncellendi."
    rescue Warehouses::StatusTransitionService::InvalidTransitionError => e
      redirect_to @warehouse, alert: "Geçersiz durum geçişi: #{e.message}"
    end
  end

  def approve_sla
    if @warehouse.throttled?
      Warehouses::StatusTransitionService.transition!(
        warehouse: @warehouse,
        to_status: "active",
        reason: "15 dk SLA penceresinde yönetici ek bütçe onayı verdi"
      )
      redirect_to @warehouse, notice: "SLA onayı verildi, ambar 'active' durumuna döndü."
    else
      redirect_to @warehouse, alert: "Ambar throttled durumunda değil."
    end
  end

  private

  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  def warehouse_params
    params.require(:warehouse).permit(:name, :size, :status, :credit_quota, :warning_threshold_pct, :department_id)
  end
end
