namespace :data do
  desc "Update Users Enable"
  task :users_enable => :environment do
    User.update_all is_active: true
  end
end
