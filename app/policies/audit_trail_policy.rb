class AuditTrailPolicy < ApplicationPolicy

	def index?
    curator? || system_admin?
  end

	def search?
    curator? || system_admin?
  end

	def export_csv?
    curator? || system_admin?
  end

end