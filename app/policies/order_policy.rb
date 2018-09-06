# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def create?
    customer?
  end

  def show?
    has_access_to_order?
  end

  def update?
    has_access_to_order?
  end

  private
    def has_access_to_order?
      seller? || customer?
    end

    def customer?
      @user.id == record.lot.user_win_id
    end

    def seller?
      @user.id == record.lot.user_id
    end
end
