FactoryBot.define do
  factory :organization do
    user

    sequence(:name) { |n| "Organization #{n}" }

    trait :with_company_car do
      after(:build) do |organization|
        organization.company_car = build(:company_car, organization: organization)
      end
    end

    trait :with_service do
      after(:build) do |organization|
        organization.services = [build(:service, organization: organization)]
      end
    end

    trait :with_service_and_phone do
      after(:build) do |organization|
        organization.services = [build(:service, organization: organization, phones: [build(:phone)])]
      end
    end
  end
end
