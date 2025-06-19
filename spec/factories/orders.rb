FactoryBot.define do
  factory :order do
    user { nil }
    status { "MyString" }
    items { "" }
  end
end
