class OrdersController < ApplicationController
  def index
    result = OrderService.fetch_user_orders(params[:user_id])
    render json: result[:data], status: result[:status]
  end

  def create
    result = OrderService.create_order(params[:user_id], order_params[:items])
    render json: result[:data], status: result[:status]
  end

  def show
    result = OrderService.fetch_order(params[:id])
    render json: result[:data], status: result[:status]
  end

  def update_status
    result = OrderService.update_status(params[:id], params[:status])
    render json: result[:data], status: result[:status]
  end

  def cancel
    result = OrderService.cancel_order(params[:id])
    render json: result[:data], status: result[:status]
  end

  private

  def order_params
    params.require(:order).permit(items: {})
  end
end
