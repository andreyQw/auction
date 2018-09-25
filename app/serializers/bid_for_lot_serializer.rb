# frozen_string_literal: true

class BidForLotSerializer < ActiveModel::Serializer
  attributes :id, :proposed_price, :created_at, :user_id, :lot_id, :user_name_alias

  def user_name_alias
    if object.user_id == current_user.id
      "You"
    else
      crypt = (object.user_id.to_s + object.lot_id.to_s).crypt("qweqwe")
      "Customer #{crypt}"
    end
  end
end
