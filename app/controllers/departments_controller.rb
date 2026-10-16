class DepartmentsController < ApplicationController
  def index
    @departments = Department.includes(:warehouses, :owner).order(:name)
  end

  def show
    @department = Department.find(params[:id])
    @warehouses = @department.warehouses.order(:name)
  end
end
