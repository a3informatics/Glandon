class IsoRegistrationStatePolicy < IsoPolicy

	def current?
    curator?
  end

  def update?
    curator?
  end

end