# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def create?
    lot = Lot.find(record.lot_id)
    @user.id == lot.user_win_id && record.status == "pending"
  end

  def show?
    has_access_to?
  end

  def update?
    has_access_to?
  end

  private
    def has_access_to?
      @user.id == record.lot.user_id || @user.id == record.lot.user_win_id
    end
end
