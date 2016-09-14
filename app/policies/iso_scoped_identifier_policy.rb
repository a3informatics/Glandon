class IsoScopedIdentifierPolicy < IsoPolicy

  def update?
    curator?
  end

private

	# TODO: Create common set in ApplicationPolicy
  def curator?
    @user.has_role? :curator or @user.has_role? :content_admin
  end

end