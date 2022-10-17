FactoryBot.define do
  factory :invoice do
    customer
    merchant
    status { "in progress" }
  end
end