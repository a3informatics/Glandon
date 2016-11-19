# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Common Setup
# 1. Create roles for Rolify
Role::C_ROLES.each do |role|
  Role.create( name: role )
end

# Enviornment-specific Setup
# 1. Create sys admin user.
case Rails.env
	when "development"
		user1 = User.create :email => "daveih1664@gmail.com", :password => "changeme" 
		user1.add_role :sys_admin
		user1.add_role :content_admin
		user1.add_role :curator
		user1.add_role :reader
	when "test"
		user1 = User.create :email => "sys_admin@example.com", :password => "changeme" 
		user1.add_role :sys_admin
		user1.add_role :content_admin
		user1.add_role :curator
		user1.add_role :reader
	when "production"
		user1 = User.create :email => "daveih1664@gmail.com", :password => "changeme" 
		user1.add_role :sys_admin
		user1.add_role :content_admin
		user1.add_role :curator
		user1.add_role :reader
end

