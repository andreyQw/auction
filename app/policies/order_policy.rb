# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def create?
    customer?
  end

  def show?
    seller? || customer?
  end

  def update?
    customer? && record.pending?
  end

  def update_status_to_sent?
    seller? && record.pending?
  end

  def update_status_to_delivered?
    customer? && record.sent?
  end

  private

    def seller?
      @user.id == record.lot.user_id
    end

    def customer?
      @user.id == record.lot.user_win_id
    end
end
