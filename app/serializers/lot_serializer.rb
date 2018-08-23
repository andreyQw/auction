# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :integer          not null, primary key
#  current_price   :float            not null
#  description     :string
#  estimated_price :float            not null
#  image           :string
#  lot_end_time    :datetime         not null
#  lot_start_time  :datetime         not null
#  status          :integer          default("pending")
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

class LotSerializer < ActiveModel::Serializer
  # attributes :id, :user_id, :title, :image, :description, :status, :current_price, :estimated_price, :lot_start_time, :lot_end_time
  attributes :id, :user_id, :title

  # belongs_to :user
  has_many :bids
end
