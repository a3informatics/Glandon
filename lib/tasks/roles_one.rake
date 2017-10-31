namespace :data do
  desc "Update Roles"
  task :roles_one => :environment do
  	Rails.configuration.roles[:roles].each { |k, v| Role.create(name: k) if !Role.exists?(name: k) }
  end
end