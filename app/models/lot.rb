class Lot < ApplicationRecord
  belongs_to :user
  has_many :bids
  has_one :order
end