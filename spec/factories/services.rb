FactoryBot.define do
  factory :service do
    organization
    sequence(:name) { |n| "Organization #{n}" }

    trait :with_phone do
      after(:build) do |service|
        service.phones = [build(:phone, service: service)]
      end
    end
  end
end
