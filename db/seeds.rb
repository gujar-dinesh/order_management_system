# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Clear existing data
# Order.destroy_all
# User.destroy_all
# InventoryItem.destroy_all

# puts "Started"
# users = [
#   { name: "Dinesh", email: "dinesh@example.com", phone: "1234567896" },
#   { name: "Alice", email: "alicee@example.com", phone: "1234567892" },
#   { name: "Bob", email: "bobe@example.com", phone: "0987654321" },
#   { name: "amit", email: "amitk@example.com", phone: "0987654334" },
# ].map { |attrs| User.create!(attrs) }
#
# puts "Seeding inventory..."
# inventory_items = [
#   { name: "burger", quantity: 10, threshold: 3 },
#   { name: "fries", quantity: 15, threshold: 5 },
#   { name: "pizza", quantity: 5, threshold: 2 }
# ].map { |item| InventoryItem.create!(item) }
#
# puts "Seeding orders..."
# orders = [
#   { user: User.first, status: "Pending", items: { "burger" => 2, "fries" => 1 } },
#   { user: User.second, status: "Pending", items: { "pizza" => 3 } },
#   { user: User.last, status: "Pending", items: { "burger" => 8 } } # this may trigger threshold logic
# ]
#
# orders.each { |attrs| Order.create!(attrs) }

# puts "Done."
# 1_000.times do
#   User.create!(
#     name: Faker::Name.name,
#     email: Faker::Internet.unique.email,
#     phone: Faker::PhoneNumber.subscriber_number(length: 10)
#   )
# end

require 'faker'

# Disable observers temporarily
# ActiveRecord::Base.observers.disable :order_observer, :inventory_item_observer do

  puts "Seeding users..."
  users = []
  10_000.times do |i|
    users << User.new(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      phone: Faker::PhoneNumber.subscriber_number(length: 10)
    )
  end
  User.import users
  puts "10,000 users created."

  puts "Seeding inventory items..."
  inventory = []
  50_000.times do |i|
    inventory << InventoryItem.new(
      name: "item_#{i + 1}",
      quantity: 200,
      threshold: 50
    )
  end
  InventoryItem.import inventory
  puts "50,000 inventory items created."

  puts "Seeding orders..."
  all_user_ids = User.pluck(:id)
  all_item_names = InventoryItem.pluck(:name)

  orders = []
  10_000.times do |i|
    user_id = all_user_ids.sample
    selected_items = all_item_names.sample(rand(1..3)) # 1 to 3 items per order
    items_hash = selected_items.to_h { |name| [name, rand(1..3)] }

    orders << Order.new(
      user_id: user_id,
      status: "Pending",
      items: items_hash
    )
  end

  Order.import orders
  puts "10,000 orders created"

# end

puts "one seeding"
