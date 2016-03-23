# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create roles for Rolify
[:sys_admin, :content_admin, :curator, :reader].each do |role|
  Role.create( name: role )
end

# Create Users
user1 = User.create :email => "daveih1664@gmail.com", :password => "changeme" 
user1.add_role :sys_admin
user1.add_role :content_admin
user1.add_role :curator
user1.add_role :reader
