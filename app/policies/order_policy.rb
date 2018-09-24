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

  def status_update?
    access_for_seller? || access_for_customer?
  end


  private
    def seller?
      @user.id == record.lot.user_id
    end

    def customer?
      @user.id == record.lot.user_win_id
    end

    def access_for_seller?
      seller? && status_from_pending_to_sent?
    end

    def access_for_customer?
      customer? && status_from_sent_to_delivered?
    end

    def status_from_pending_to_sent?
      status_was_pending? && record.sent?
    end

    def status_from_sent_to_delivered?
      status_was_sent? && record.delivered?
    end

    def status_was_pending?
      record.status_was == "pending"
    end

    def status_was_sent?
      record.status_was == "sent"
    end
end
