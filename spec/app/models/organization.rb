class Organization < ApplicationRecord
  belongs_to :user

  has_one :company_car

  has_many :services, dependent: :destroy
  has_many :subsidiaries, foreign_key: :parent_id, class_name: 'Organization', dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :services, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :company_car, reject_if: :all_blank, allow_destroy: true
end
