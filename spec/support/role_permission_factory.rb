module RolePermissionFactory
  
  def create_role_permission(params)
    Role::Permission.create(params)
  end

end