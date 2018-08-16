# frozen_string_literal: true

class LotPolicy < ApplicationPolicy
  def update?
    user_has_crud_permits?
  end

  def destroy?
    user_has_crud_permits?
  end

  def show?
    record.user_id == user.id || record.status == "in_process"
  end

  private
    def user_has_crud_permits?
      record.user_id == user.id && record.status == "pending"
    end
end
