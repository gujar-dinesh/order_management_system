# lib/kafka_producer.rb
require 'kafka'
require 'json'

class KafkaProducer
  def initialize(brokers = ['localhost:9092'])
    @kafka = Kafka.new(brokers)
    @producer = @kafka.async_producer
  end

  def publish(topic, message)
    @producer.produce(message.to_json, topic: topic)
    @producer.deliver_messages
  rescue => e
    puts "Error publishing message: #{e.message}"
  end
end
