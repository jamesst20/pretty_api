FactoryBot.define do
  factory :company_car do
    organization
    sequence(:brand) { |n| "Brand #{n}" }
  end
end
