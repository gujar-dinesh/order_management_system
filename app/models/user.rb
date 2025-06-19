class User < ApplicationRecord

  has_many :orders, dependent: :destroy

  validates :name, presence: true

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{10}\z/, message: "Must be exactly 10 digits" }
end
