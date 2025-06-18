class OrdersController < ApplicationController
  def create
    user = User.find_by(id: params[:user_id])
    return render json: { error: "User not found" }, status: :not_found unless user
    order = user.orders.build(order_params.merge(status: "Pending"))

    if order.save
      # handle_order_placed(order)
      order.reload
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    order = Order.find_by(id: params[:id])
    return render json: { error: "Order not found" }, status: :not_found unless order

    render json: order
  end

  def update_status
    order = Order.find_by(id: params[:id])
    return render json: { error: "Order not found" }, status: :not_found unless order

    status = params[:status]
    unless Order::VALID_STATUSES.include?(status)
      return render json: { error: "Invalid status" }, status: :unprocessable_entity
    end

    if order.update(status: status)
      handle_order_status_updated(order)
      render json: order
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def cancel
    order = Order.find_by(id: params[:id])
    return render json: { error: "Order not found" }, status: :not_found unless order

    if order.status == "Confirmed"
      restore_inventory(order)
    end

    order.update(status: "Cancelled")
    handle_order_cancelled(order)

    render json: order
  end


  private

  def order_params
    params.require(:order).permit(items: {})
  end

  def handle_order_status_updated(order)
    Rails.logger.info("[Order Status Updated] Order ##{order.id} status changed to #{order.status}")
    # Add logic here for analytics, notifications, etc.
  end

  def handle_order_cancelled(order)
    Rails.logger.info("[Order Cancelled] Order ##{order.id} was cancelled")
    # Add cleanup/rollback logic if needed
  end

  def restore_inventory(order)
    order.items.each do |item_name, quantity|
      item = InventoryItem.find_by(name: item_name)
      item.increment!(:quantity, quantity) if item
    end
  end
end
