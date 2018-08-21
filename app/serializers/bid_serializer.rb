# == Schema Information
#
# Table name: bids
#
#  id             :integer          not null, primary key
#  nickname       :string
#  proposed_price :float
#  created_at     :datetime
#  lot_id         :integer
#  user_id        :integer
#
# Indexes
#
#  index_bids_on_lot_id   (lot_id)
#  index_bids_on_user_id  (user_id)
#

class BidSerializer < ActiveModel::Serializer
  attributes :id, :proposed_price, :nickname

  # belongs_to :user
  # belongs_to :lot
end