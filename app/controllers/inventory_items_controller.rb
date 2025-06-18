class InventoryItemsController < ApplicationController
  before_action :set_inventory_item, only: [:update, :destroy]

  def index
    inventory = InventoryItem.all
    render json: inventory
  end

  def create
    item = InventoryItem.new(inventory_params)

    if item.save
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @inventory_item.update(inventory_params)
      render json: @inventory_item
    else
      render json: { errors: @inventory_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @inventory_item.destroy
    head :no_content
  end

  private

  def set_inventory_item
    @inventory_item = InventoryItem.find_by(id: params[:id])
    render json: { error: "Item not found" }, status: :not_found unless @inventory_item
  end

  def inventory_params
    params.require(:inventory_item).permit(:name, :quantity, :threshold)
  end
end
