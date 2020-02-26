namespace :users do
  desc "Update Users Enable"
  task :active => :environment do
    User.update_all is_active: true
  end
end
