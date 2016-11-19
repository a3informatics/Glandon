class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles

  belongs_to :resource,
             :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  C_CLASS_NAME = "Role"
  C_SYS_ADMIN = :sys_admin
  C_CONTENT_ADMIN = :content_admin
  C_CURATOR = :curator
  C_READER = :reader
  C_ROLES = [C_SYS_ADMIN, C_CONTENT_ADMIN, C_CURATOR, C_READER]

  @@map_to_s = {C_SYS_ADMIN => "System Admin", C_CONTENT_ADMIN => "Content Admin", C_CURATOR => "Curator", C_READER => "Reader"}

  # Return role as a human readable string
  #
  # @param role [symbol] The role
  # @return [string] The role string if found, otherwise empty
  def self.role_to_s(role_name)
  	return @@map_to_s[role_name.to_sym] if @@map_to_s.has_key?(role_name.to_sym)
  	return ""
  end

	scopify
end
