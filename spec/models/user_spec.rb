require 'rails_helper'

RSpec.describe User, type: :model do
  subject { described_class.new(name: "John Doe", email: "john@example.com", phone: "1234567890") }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid without a name" do
    subject.name = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to include("can't be blank")
  end

  it "is invalid without an email" do
    subject.email = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include("can't be blank")
  end

  it "is invalid with improperly formatted email" do
    subject.email = "invalid_email"
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include("is invalid")
  end

  it "is invalid without a phone number" do
    subject.phone = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:phone]).to include("can't be blank")
  end

  it "is invalid with non-10-digit phone number" do
    subject.phone = "12345"
    expect(subject).not_to be_valid
    expect(subject.errors[:phone]).to include("Must be exactly 10 digits")
  end

  it "is invalid with non-numeric phone number" do
    subject.phone = "abcdefghij"
    expect(subject).not_to be_valid
    expect(subject.errors[:phone]).to include("Must be exactly 10 digits")
  end

  it "has many orders and deletes them when user is deleted" do
    subject.save!
    subject.orders.create!(items: { "burger" => 1 }, status: "Confirmed")
    expect { subject.destroy }.to change { Order.count }.by(-1)
  end
end
