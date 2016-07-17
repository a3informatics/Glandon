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

  def import_file?
    content_admin?
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
    @user.has_role? :reader or @user.has_role? :curator or @user.has_role? :content_admin 
  end

  def curator?
    @user.has_role? :curator or @user.has_role? :content_admin
  end

  def content_admin?
    @user.has_role? :content_admin
  end

end
