FactoryBot.define do
  factory :item do
    name { Faker::Company.name }
    description { Faker::Lorem.sentence }
    unit_price { Faker::Number.within(range: 1..999999) }
    merchant
  end
end