class CompanyCar < ApplicationRecord
  belongs_to :organization

  validates :brand, presence: true

  accepts_nested_attributes_for :organization, reject_if: :all_blank, allow_destroy: true
end
