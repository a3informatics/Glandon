namespace :reports do
  desc "Ad Hoc Reports Clobber"
  task :clobber => :environment do
    AdHocReportFiles.destroy_all
  end
end
