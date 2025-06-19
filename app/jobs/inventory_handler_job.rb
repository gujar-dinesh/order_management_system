# class InventoryHandlerJob
#   include Sidekiq::Worker
#
#   def perform(order_id)
#     order = Order.find( order_id)
#     return unless order.status == "Pending"
#
#     items = order.items
#     inventory = InventoryItem.where(name: items.keys).index_by(&:name)
#
#     # Check if all items are available
#     can_fulfill = !items.any? do |item_name, quantity|
#       inventory[item_name]&.quantity.to_i < quantity.to_i
#     end
#
#     if can_fulfill
#       # Deduct inventory
#       items.each do |item_name, quantity|
#         inv = inventory[item_name]
#         inv.update!(quantity: inv.quantity - quantity.to_i)
#       end
#       order.update!(status: "Confirmed")
#     else
#       order.update!(status: "Rejected")
#     end
#   end
# end

class InventoryHandlerJob
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    return unless order.status == "Pending"

    items = order.items

    ActiveRecord::Base.transaction do
      # Lock inventory rows
      inventory = InventoryItem.where(name: items.keys).lock(true).index_by(&:name)

      # Check if all items can be fulfilled
      can_fulfill = !items.any? do |item_name, quantity|
        inventory[item_name]&.quantity.to_i < quantity.to_i
      end

      if can_fulfill
        items.each do |item_name, quantity|
          inv = inventory[item_name]
          inv.update!(quantity: inv.quantity - quantity.to_i)
        end
        order.update!(status: "Confirmed")
      else
        order.update!(status: "Rejected")
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("Order #{order_id} not found: #{e.message}")
  rescue ActiveRecord::Deadlocked
    # Optional: retry on deadlock
    retry
  end
end
