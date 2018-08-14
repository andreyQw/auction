class LotSerializer < ActiveModel::Serializer
  # attributes :id, :user_id, :image, :description, :status, :current_price, :estimated_price, :lot_start_time, :lot_end_time, :created_at, :updated_at
  attributes :id, :description, :status, :current_price

  belongs_to :user
  has_many :bids
  has_one :order
end
