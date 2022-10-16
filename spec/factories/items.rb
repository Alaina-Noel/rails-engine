FactoryBot.define do
  factory :item do
    name { Faker::Business.name }
    description { Faker::Lorem.sentence }
    unit_price { Faker::Number.within(range: 1..999999) }
    merchant
  end
end