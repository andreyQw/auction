# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  birthday   :date
#  email      :string
#  first_name :string
#  last_name  :string
#  password   :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
	has_many :lots
	has_many :bids
end
