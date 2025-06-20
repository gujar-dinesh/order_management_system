class OrderConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      update_order_status(message.payload)
    end
  end

  private

  def update_order_status(payload)
    order_id, new_status = extract_order_data(payload)
    return unless order_id && new_status

    order = Order.find_by(id: order_id)
    return unless order

    previous_status = order.status
    return if previous_status == new_status

    ActiveRecord::Base.transaction do
      order.update!(status: new_status)

      if previous_status == "Confirmed" && new_status == "Cancelled"
        order.items.each do |item_name, quantity|
          inv = InventoryItem.find_by(name: item_name)
          inv.increment!(:quantity, quantity) if inv
        end
      end
    end

    Karafka.logger.info("[OrderConsumer] Order ##{order.id} status updated from #{previous_status} to #{new_status}")
  rescue => e
    Karafka.logger.error("Failed to update order #{order_id} to #{new_status}: #{e.message}")
  end

  def extract_order_data(payload)
    case payload
    when String
      data = JSON.parse(payload)
    when Hash
      data = payload
    else
      return [nil, nil]
    end

    [data["order_id"], data["new_status"]]
  rescue JSON::ParserError => e
    Karafka.logger.error("Invalid payload: #{payload}. Error: #{e.message}")
    [nil, nil]
  end
end
