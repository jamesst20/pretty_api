class User < ApplicationRecord
  has_many :organizations, dependent: :destroy
  has_many :children, class_name: "User", foreign_key: "parent_id", dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :organizations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :children, reject_if: :all_blank, allow_destroy: true
end
