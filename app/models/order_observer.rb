require_relative '../../lib/kafka_producer'
class OrderObserver < ActiveRecord::Observer

  # def after_create(order)
  #   InventoryHandlerJob.perform_async(order.id)
  # end
  def after_create(order)
    producer = KafkaProducer.new
    producer.publish('inventory', { order_id: order.id }.to_json)

    puts "Event published!"
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
