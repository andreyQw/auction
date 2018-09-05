# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def create?
    @user.id == record.lot.user_win_id
  end

  def show?
    has_access_to_order?
  end

  def update?
    has_access_to_order?
  end

  private
    def has_access_to_order?
      @user.id == record.lot.user_id || @user.id == record.lot.user_win_id
    end

end
