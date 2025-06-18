class OrderObserver < ActiveRecord::Observer

  def after_create(order)
    # InventoryHandlerJob.perform_async(order.id)
     order = Order.find_by(id: order.id)
        return unless order.status == "Pending"

        items = order.items
        inventory = InventoryItem.where(name: items.keys).index_by(&:name)

        # Check if all items are available
        can_fulfill = items.all? do |item_name, quantity|
          inventory[item_name]&.quantity.to_i >= quantity.to_i
        end

        if can_fulfill
          # Deduct inventory
          items.each do |item_name, quantity|
            inv = inventory[item_name]
            inv.update!(quantity: inv.quantity - quantity.to_i)
          end
          order.update!(status: "Received")
        else
          order.update!(status: "Rejected")
        end
  end


  def before_update(order)
    return unless order.status_changed? &&
      order.status == "Cancelled" &&
      order.status_was == "Confirmed"

    order.items.each do |item_name, quantity|
      inv = InventoryItem.find_by(name: item_name)
      inv.increment!(:quantity, quantity) if inv
    end
  end
end
