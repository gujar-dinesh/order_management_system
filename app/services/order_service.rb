class OrderService
  def self.fetch_user_orders(user_id)
    user = User.find_by(id: user_id)
    return { data: { error: "User not found" }, status: :not_found } unless user

    orders = user.orders.order(created_at: :desc).limit(10)
    { data: orders, status: :ok }
  end

  def self.create_order(user_id, items)
    return { data: { error: "User not found" }, status: :not_found } unless User.exists?(id: user_id)

    order = Order.new(items: items, status: "Pending", user_id: user_id)

    if order.save
      # Optionally trigger Sidekiq job
      # InventoryHandlerJob.perform_async(order.id)
      { data: order, status: :created }
    else
      { data: { errors: order.errors.full_messages }, status: :unprocessable_entity }
    end
  end

  def self.fetch_order(id)
    order = Order.select(:id, :status, :items).find_by(id: id)
    return { data: { error: "Order not found" }, status: :not_found } unless order

    { data: order, status: :ok }
  end

  def self.update_status(id, new_status)
    order = Order.find_by(id: id)
    return { data: { error: "Order not found" }, status: :not_found } unless order

    unless Order::VALID_STATUSES.include?(new_status)
      return { data: { error: "Invalid status" }, status: :unprocessable_entity }
    end

    if order.update(status: new_status)
      Rails.logger.info("[Order Status Updated] Order ##{order.id} status changed to #{new_status}")
      { data: order, status: :ok }
    else
      { data: { errors: order.errors.full_messages }, status: :unprocessable_entity }
    end
  end

  def self.cancel_order(id)
    order = Order.find_by(id: id)
    return { data: { error: "Order not found" }, status: :not_found } unless order

    if order.status == "Confirmed"
      order.items.each do |item_name, quantity|
        item = InventoryItem.find_by(name: item_name)
        item.increment!(:quantity, quantity) if item
      end
    end

    order.update(status: "Cancelled")
    Rails.logger.info("[Order Cancelled] Order ##{order.id} was cancelled")

    { data: order, status: :ok }
  end
end
