class User < ApplicationRecord
	has_many :lots
	has_many :bids
end
