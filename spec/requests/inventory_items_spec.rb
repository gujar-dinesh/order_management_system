require 'rails_helper'

RSpec.describe "InventoryItems API", type: :request do
  let!(:inventory_item) { InventoryItem.create!(name: "burger", quantity: 10, threshold: 3) }

  describe "GET /inventory_items" do
    it "returns all inventory items" do
      get "/inventory_items"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 1
    end
  end

  describe "POST /inventory_items" do
    it "creates a new inventory item" do
      post "/inventory_items", params: {
        inventory_item: {
          name: "fries",
          quantity: 20,
          threshold: 5
        }
      }

      expect(response).to have_http_status(:created)
      expect(InventoryItem.find_by(name: "fries")).to be_present
    end

    it "returns error for missing fields" do
      post "/inventory_items", params: { inventory_item: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /inventory_items/:id" do
    it "updates an inventory item" do
      put "/inventory_items/#{inventory_item.id}", params: {
        inventory_item: {
          quantity: 5,
          threshold: 2
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["quantity"]).to eq(5)
    end
  end

  describe "DELETE /inventory_items/:id" do
    it "deletes an inventory item" do
      expect {
        delete "/inventory_items/#{inventory_item.id}"
      }.to change { InventoryItem.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
