class Order < ApplicationRecord
  belongs_to :user

  VALID_STATUSES = %w[Pending Received Confirmed OutForDelivery Delivered Rejected Cancelled]

  validates :status, inclusion: { in: VALID_STATUSES }
  validates :items, presence: true


end
