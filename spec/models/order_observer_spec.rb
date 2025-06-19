require 'rails_helper'

RSpec.describe OrderObserver, type: :observer do
  let!(:user) { User.create!(name: "Observer Test", email: "observer@test.com", phone: "1234567890") }
  let!(:inventory_item) { InventoryItem.create!(name: "burger", quantity: 10, threshold: 2) }

  before do
    ActiveRecord::Base.observers.enable :order_observer
  end

  describe "after_create" do
    it "enqueues InventoryHandlerJob" do
      expect(InventoryHandlerJob).to receive(:perform_async).with(instance_of(Integer))
      user.orders.create!(items: { "burger" => 2 }, status: "Pending")
    end
  end

  describe "before_update" do
    it "restores inventory when status changes from Confirmed to Cancelled" do
      order = user.orders.create!(items: { "burger" => 2 }, status: "Confirmed")
      inventory_item.update!(quantity: 8) # simulate deducted inventory

      expect {
        order.update!(status: "Cancelled")
      }.to change { inventory_item.reload.quantity }.by(2)
    end

    it "does not restore inventory if status does not change" do
      order = user.orders.create!(items: { "burger" => 2 }, status: "Pending")
      expect {
        order.update!(items: { "burger" => 3 })
      }.not_to change { inventory_item.reload.quantity }
    end
  end
end
