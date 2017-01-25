class ApplicationPolicy
  
  C_CLASS_NAME = "ApplicationPolicy"
  
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    reader?
  end

  def show?
    reader?
  end

  def view?
    reader?
  end

  def list?
    reader?
  end

  def history?
    reader?
  end

  def create?
    curator?
  end

  def new?
    curator?
  end

  def update?
    curator?
  end

  def edit?
    curator?
  end

  def clone?
    curator?
  end

  def branch?
    curator?
  end

  def upgrade?
    curator?
  end
  
  def impact?
    curator?
  end

  def import?
    content_admin?
  end

  def destroy?
    curator?
  end

  def export_json?
    curator?
  end

  def export_ttl?
    curator?
  end
  
  def export_csv?
    curator?
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
    #@user.has_role? Role::C_READER or @user.has_role? Role::C_CURATOR or @user.has_role? Role::C_CONTENT_ADMIN
    return @user.is_a_reader?
  end

  def curator?
    #@user.has_role? Role::C_CURATOR or @user.has_role? Role::C_CONTENT_ADMIN
    return @user.is_a_curator?
  end

  def content_admin?
    #@user.has_role? Role::C_CONTENT_ADMIN
    return @user.is_a_content_admin?
  end

  def system_admin?
    #@user.has_role? Role::C_SYS_ADMIN
    return @user.is_a_system_admin?
  end

end
