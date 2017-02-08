class TokenPolicy < ApplicationPolicy

	def index?
    system_admin?
  end

	def release?
    curator? || system_admin?
  end

  def status?
    curator?
  end

  def extend_token?
    curator?
  end  	

end