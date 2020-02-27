namespace :roles do
  desc "Update Roles"
  task :update => :environment do
  	Rails.configuration.roles[:roles].each { |k, v| Role.create(name: k) if !Role.exists?(name: k) }
  end
end