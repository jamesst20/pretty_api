FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }

    trait :with_child do
      after(:build) do |user|
        user.children = [build(:user)]
      end
    end
  end
end
