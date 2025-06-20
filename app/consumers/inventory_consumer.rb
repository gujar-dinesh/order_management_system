class InventoryConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      process_inventory(message.payload)
    end
  end

  private

  def process_inventory(payload)
    order_id = extract_order_id(payload)
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order && order.status == "Pending"

    items = order.items

    ActiveRecord::Base.transaction do
      # Lock relevant inventory rows
      inventory = InventoryItem.where(name: items.keys).lock(true).index_by(&:name)

      # Check if inventory is sufficient
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
  rescue ActiveRecord::Deadlocked
    # Optional retry logic (avoid infinite loops!)
    Karafka.logger.warn("Deadlock occurred while processing order #{order_id}. Retrying...")
    retry
  rescue => e
    Karafka.logger.error("Failed to process inventory for order #{order_id}: #{e.message}")
  end

  def extract_order_id(payload)
    case payload
    when String
      JSON.parse(payload)["order_id"]
    when Hash
      payload["order_id"]
    else
      nil
    end
  rescue JSON::ParserError => e
    Karafka.logger.error("Invalid payload format: #{payload}. Error: #{e.message}")
    nil
  end
end
