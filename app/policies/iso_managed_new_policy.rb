class IsoManagedPolicy < IsoPolicy

  def status?
    @user.has_role? :content_admin
  end

end