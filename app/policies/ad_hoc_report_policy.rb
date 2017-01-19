class AdHocReportPolicy < ApplicationPolicy

	def index?
    curator?
  end

  def create?
    content_admin?
  end

  def run_start?
    curator?
  end

  def run_progress?
    curator?
  end

  def run_results?
    curator?
  end

  def results?
    curator?
  end

  def show?
    curator?
  end

  def destroy?
    content_admin?
  end

end