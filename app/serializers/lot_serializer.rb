# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id                :integer          not null, primary key
#  bid_win           :integer
#  current_price     :float            not null
#  description       :string
#  estimated_price   :float            not null
#  image             :string
#  job_id_closed     :string
#  job_id_in_process :string
#  lot_end_time      :datetime         not null
#  lot_start_time    :datetime         not null
#  status            :integer          default("pending")
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#  user_win_id       :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

class LotSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :image, :description, :status, :current_price, :estimated_price,
             :lot_start_time, :lot_end_time, :bid_win, :user_win_id, :job_id_in_process, :job_id_closed

  # belongs_to :user

  has_many :bids, serializer: BidForLotSerializer
  # has_many :bids
end
