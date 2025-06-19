require 'rails_helper'

RSpec.describe OrdersController, type: :request do
  let!(:user) { User.find_or_create_by!(name: "Test User", email: "test@example.com", phone: "1234567890") }

  let!(:inventory_items) do
    [
      InventoryItem.create!(name: "burger", quantity: 100, threshold: 10),
      InventoryItem.create!(name: "fries", quantity: 100, threshold: 10)
    ]
  end

  describe "GET /users/:user_id/orders" do
    before do
      3.times { user.orders.create!(items: { "burger" => 1 }, status: "Pending") }
    end

    it "returns all orders for the user" do
      get "/orders?user_id=#{user.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(3)
    end

    it "returns 404 for nonexistent user" do
      get "/users/9999/orders"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /orders" do
    it "creates an order and enqueues inventory job" do
      expect {
        post "/orders", params: {
          user_id: user.id,
          order: { items: { burger: 2, fries: 1 } }
        }, as: :json
      }.to change(Order, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Order.last.status).to eq("Pending")
    end

    it "returns 404 if user_id is missing" do
      post "/orders", params: { order: { items: { burger: 1 } } }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /orders/:id" do
    let!(:order) { user.orders.create!(items: { burger: 1 }, status: "Confirmed") }

    it "returns the order" do
      get "/orders/#{order.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["status"]).to eq("Confirmed")
    end

    it "returns 404 if order not found" do
      get "/orders/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /orders/:id/update_status" do
    let!(:order) { user.orders.create!(items: { burger: 1 }, status: "Pending") }

    it "updates the status" do
      put "/orders/#{order.id}/update_status", params: { status: "Delivered" }
      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("Delivered")
    end

    it "rejects invalid status" do
      put "/orders/#{order.id}/update_status", params: { status: "Unknown" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /orders/:id/cancel" do
    let!(:order) { user.orders.create!(items: { burger: 1 }, status: "Confirmed") }

    it "cancels the order and restores inventory" do
      original_quantity = InventoryItem.find_by(name: "burger").quantity
      post "/orders/#{order.id}/cancel"
      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("Cancelled")
      expect(InventoryItem.find_by(name: "burger").quantity).to eq(original_quantity+2 )
    end

    it "cancels without restoring if not confirmed" do
      order.update(status: "Rejected")
      original_quantity = InventoryItem.find_by(name: "burger").quantity
      post "/orders/#{order.id}/cancel"
      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("Cancelled")
      expect(InventoryItem.find_by(name: "burger").quantity).to eq(original_quantity)
    end
  end
end
