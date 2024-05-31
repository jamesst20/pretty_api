class Phone < ApplicationRecord
  belongs_to :service

  validates :number, presence: true
end
