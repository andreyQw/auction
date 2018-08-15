
class LotPolicy < ApplicationPolicy
  def update?
    has_crud_permits?
  end

  def destroy?
    has_crud_permits?
  end

  def show?
    record.user_id == user.id || record.status == "inProgress"
  end

  private
  def has_crud_permits?
    record.user_id == user.id && record.status == "pending"
  end
end