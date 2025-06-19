require 'rails_helper'

RSpec.describe InventoryHandlerJob, type: :job do
  let!(:user) { User.create!(name: "Test User", email: "test@example.com", phone: "1234567890") }
  let!(:inventory_items) do
    [
      InventoryItem.create!(name: "burger", quantity: 10, threshold: 2),
      InventoryItem.create!(name: "fries", quantity: 5, threshold: 1)
    ]
  end

  context "when order can be fulfilled" do
    let!(:order) { user.orders.create!(items: { "burger" => 2, "fries" => 1 }, status: "Pending") }

    it "confirms the order and deducts inventory" do
      expect {
        InventoryHandlerJob.new.perform(order.id)
      }.to change { order.reload.status }.from("Pending").to("Confirmed")

      expect(InventoryItem.find_by(name: "burger").quantity).to eq(8)
      expect(InventoryItem.find_by(name: "fries").quantity).to eq(4)
    end
  end

  context "when order cannot be fulfilled" do
    let!(:order) { user.orders.create!(items: { "burger" => 100 }, status: "Pending") }

    it "rejects the order" do
      expect {
        InventoryHandlerJob.new.perform(order.id)
      }.to change { order.reload.status }.from("Pending").to("Rejected")
    end
  end

  context "when order is not pending" do
    let!(:order) { user.orders.create!(items: { "burger" => 1 }, status: "Confirmed") }

    it "does nothing" do
      expect {
        InventoryHandlerJob.new.perform(order.id)
      }.not_to change { order.reload.status }
    end
  end

  context "when order is not found" do
    it "logs a warning and does not raise" do
      expect(Rails.logger).to receive(:warn).with(/Order 9999 not found/)
      expect { InventoryHandlerJob.new.perform(9999) }.not_to raise_error
    end
  end
end
