FactoryBot.define do
  factory :phone do
    service
    sequence(:number) { |n| "Number #{n}" }
  end
end
