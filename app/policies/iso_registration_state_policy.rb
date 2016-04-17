class IsoRegistrationStatePolicy < IsoPolicy

	def current?
    	@user.has_role? :sys_admin
  	end

end