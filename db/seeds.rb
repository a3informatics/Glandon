# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Common Setup
# 1. Create roles for Rolify
Role.destroy_all
Rails.configuration.roles[:roles].each { |k, v| Role.create(name: k) }

# Enviornment-specific Setup
# 1. Create sys admin user.
default_password = "Changeme1%1"
User.destroy_all
NameValue.destroy_all
NameValue.create(name: "thesaurus_parent_identifier", value: "1")
NameValue.create(name: "thesaurus_child_identifier", value: "1")
case Rails.env
	when "development"
		user1 = User.create :email => "daveih1664@gmail.com", :password => default_password
		user1.add_role :sys_admin
		user1.add_role :content_admin
	when "test"
		user1 = User.create :email => "test_seed@example.com", :password => default_password
		user1.add_role :sys_admin
		user1.add_role :content_admin
	when "production"
		user1 = User.create :email => "daveih1664@gmail.com", :password => default_password
		user1.add_role :sys_admin
		user1.add_role :content_admin
end

