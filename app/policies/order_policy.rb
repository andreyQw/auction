# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def create?
    customer?
  end

  def show?
    seller? || customer?
  end

  def update?
    has_access_to_update_order?
  end


  private
    def seller?
      @user.id == record.lot.user_id
    end

    def customer?
      @user.id == record.lot.user_win_id
    end

    def has_access_to_update_order?
      access_seller? || access_customer?
    end

    def access_seller?
      seller_status_change? && !seller_others_params_change?
    end

    def seller_status_change?
      seller? && status_from_pending_to_sent?
    end

    def seller_others_params_change?
      seller? && (arrival_type_change? || arrival_location_change?)
    end


    def access_customer?
      customer_status_case? || customer_others_params?
    end

    def customer_status_case?
      customer? && status_from_sent_to_delivered?
    end

    def customer_others_params?
      customer? && status_was_pending? && !status_change?
    end

    def status_change?
      record.status != record.status_was
    end

    def status_was_pending?
      record.status_was == "pending"
    end

    def status_from_pending_to_sent?
      status_was_pending? && record.sent?
    end

    def status_from_sent_to_delivered?
      record.status_was == "sent" && record.status == "delivered"
    end

    def arrival_type_change?
      record.arrival_type != record.arrival_type_was
    end

    def arrival_location_change?
      record.arrival_location != record.arrival_location_was
    end
end
