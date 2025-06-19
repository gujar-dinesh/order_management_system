require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  subject { described_class.new(name: "burger", quantity: 100, threshold: 10) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid without a name" do
    subject.name = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to include("can't be blank")
  end

  it "is invalid with a duplicate name" do
    subject.save!
    duplicate = described_class.new(name: "burger", quantity: 5, threshold: 2)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to include("has already been taken")
  end

  it "is invalid with negative quantity" do
    subject.quantity = -1
    expect(subject).not_to be_valid
    expect(subject.errors[:quantity]).to include("must be greater than or equal to 0")
  end

  it "is invalid with negative threshold" do
    subject.threshold = -5
    expect(subject).not_to be_valid
    expect(subject.errors[:threshold]).to include("must be greater than or equal to 0")
  end

  it "logs a warning when quantity falls below threshold" do
    subject.save!
    expect(Rails.logger).to receive(:warn).with("[Inventory Alert] burger is below threshold! (5/10)")
    subject.update(quantity: 5)
  end
end
