class IsoManagedPolicy < ApplicationPolicy

  def status?
    @user.has_role? :content_admin
  end

end