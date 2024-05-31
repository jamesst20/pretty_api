class Service < ApplicationRecord
  belongs_to :organization

  has_many :phones, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :phones, reject_if: :all_blank, allow_destroy: true
end
