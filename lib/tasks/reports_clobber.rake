namespace :reports do
  desc "Ad Hoc Reports Clobber"
  task :clobber => :environment do
    AdHocReport.delete_all
  end
end
