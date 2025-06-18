# app/models/inventory_item.rb
class InventoryItem < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :threshold, numericality: { greater_than_or_equal_to: 0 }

  after_update :check_threshold

  def check_threshold
    if quantity < threshold
      Rails.logger.warn("[Inventory Alert] #{name} is below threshold! (#{quantity}/#{threshold})")
    end
  end
end
