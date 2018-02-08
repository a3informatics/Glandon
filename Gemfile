source 'https://rubygems.org'
#johannes ruby '2.3.1'
ruby '2.2.3'

#johannes
gem 'ruby_dep', '~> 1.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'

# Use PG as the database for Active Record
#johannes
# gem 'pg'
# gem 'pg', '~> 0.9.0'
gem 'pg', '~> 0.19.0'

# Use SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.3.5'
gem 'sass-rails', '>= 3.2'

# Devise
gem 'devise'

# REST
gem 'typhoeus'

# Difference comparison
gem 'diffy'

# XML
#johannes gem 'nokogiri', '~> 1.6.6.2'
gem 'nokogiri', '1.6.6.2'

#johannes
gem 'tzinfo-data'

#johannes
gem'coffee-script-source','1.8.0'

# CORS
gem 'rack-cors', :require => 'rack/cors'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem "jquery-validation-rails"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# D3 gem
gem "d3-rails", "3.4.11"

# Datatables
gem 'jquery-datatables-rails'

# Delayed job
gem 'delayed_job_active_record'

# PDF gem. Prawn and Wicked_PDF. Prawn not doing everythign that is needed.
gem 'prawn'
gem 'prawn-table'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Rolify role management and Pundit authorization
gem 'rolify'
gem 'pundit'

# Markdown support
gem 'redcarpet'

# Excel support
gem 'roo', '~> 2.4.0'

# ODM support
gem 'odm', '~> 1.0.3', :git => 'https://github.com/daveih/odm.git'
gem "font-awesome-rails"

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  gem 'web-console', '~> 2.0'
  gem 'better_errors'
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout' 
end

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem "teaspoon-mocha"
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'selenium-webdriver'
end

group :production do
  gem "passenger", ">= 5.0.25", require: "phusion_passenger/rack_handler"
  gem 'daemons'
end



