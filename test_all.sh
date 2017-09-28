echo "Execute Glandon Tests, All Tests"
RAILS_ENV=test bin/rake db:setup
bin/rspec
rake teaspoon