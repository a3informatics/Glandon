echo "Execute Glandon Tests, Skip CT Bulk Tests"
RAILS_ENV=test bin/rake db:setup
bin/rspec --tag ~ct_bulk_test