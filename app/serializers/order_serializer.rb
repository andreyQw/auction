
class OrderSerializer < ActiveModel::Serializer
  attributes :id, :lot_id, :status, :arrival_type, :arrival_location
end