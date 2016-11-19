class IsoManagedPolicy < ApplicationPolicy

  def status?
    curator?
  end

end