require 'rails_helper'

RSpec.describe "Orders API", type: :request do
  let!(:user) { User.create!(name: "Test User", email: "test@example.com", phone: "1234567890") }
  let!(:inventory) do
    [
      InventoryItem.create!(name: "burger", quantity: 10, threshold: 3),
      InventoryItem.create!(name: "fries", quantity: 5, threshold: 2)
    ]
  end

  describe "POST /orders" do
    it "creates an order and mark received if inventory is sufficient" do
      post "/orders", params: {
        user_id: user.id,
        order: {
          items: {
            burger: 2,
            fries: 1
          }
        }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Received")

      burger = InventoryItem.find_by(name: "burger")
      fries = InventoryItem.find_by(name: "fries")
      expect(burger.quantity).to eq(8)
      expect(fries.quantity).to eq(4)
    end

    it "creates an order and rejects if inventory is insufficient" do
      post "/orders", params: {
        user_id: user.id,
        order: {
          items: {
            burger: 100
          }
        }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Rejected")
    end

    it "returns 404 if user is not found" do
      post "/orders", params: {
        user_id: 999,
        order: { items: { burger: 1 } }
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /orders/:id" do
    let!(:order) { user.orders.create!(items: { burger: 1 }, status: "Pending") }

    it "returns the order details" do
      get "/orders/#{order.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Received")
    end

    it "returns 404 for invalid order" do
      get "/orders/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /orders/:id/update_status" do
    let!(:order) { user.orders.create!(items: { burger: 1 }, status: "Pending") }

    it "updates status to Delivered" do
      put "/orders/#{order.id}/update_status", params: { status: "Delivered" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["status"]).to eq("Delivered")
    end

    it "rejects invalid status" do
      put "/orders/#{order.id}/update_status", params: { status: "InvalidStatus" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /orders/:id/cancel" do
    let!(:order) do
      user.orders.create!(items: { burger: 2 }, status: "Confirmed")
    end

    it "cancels the order and restores inventory" do
      post "/orders/#{order.id}/cancel"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Cancelled")
      expect(InventoryItem.find_by(name: "burger").quantity).to eq(14)
    end
  end
end
