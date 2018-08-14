class UserSerializer < ActiveModel::Serializer
  attributes :id, :email

  has_many :lots
  has_many :bids
end
