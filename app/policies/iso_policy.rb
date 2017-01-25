class IsoPolicy
  
  C_CLASS_NAME = "IsoPolicy"
  
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    system_admin?
  end

  def show?
    system_admin?
  end

  def create?
    system_admin?
  end

  def new?
    system_admin?
  end

  def update?
    system_admin?
  end

  def edit?
    system_admin?
  end

  def destroy?
    system_admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

private

  def reader?
    return @user.is_a_reader?
  end

  def curator?
    return @user.is_a_curator?
  end

  def content_admin?
    return @user.is_a_content_admin?
  end

  def system_admin?
    return @user.is_a_system_admin?
  end

end
