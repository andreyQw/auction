# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :integer          not null, primary key
#  current_price   :decimal(, )
#  description     :string
#  estimated_price :decimal(, )
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  status          :integer          default("pending")
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

class Lot < ApplicationRecord
  belongs_to :user
  has_many :bids
  has_one :order

  enum status: [ :pending, :inProcess, :closed ]
end
