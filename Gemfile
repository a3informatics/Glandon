source 'https://rubygems.org'
#ruby '2.4.4'
ruby ">=2.4.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.10'

# Use PG as the database for Active Record
gem 'pg', '~> 0.21.0'

# Use SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.3.5'
gem 'sass-rails', '>= 3.2'

# Devise
gem 'devise', '4.5.0'
gem 'devise-security', '0.13.0'
gem 'rails_email_validator'

# REST
gem 'typhoeus'

# Difference comparison
gem 'diffy'

# XML
gem 'nokogiri', '~> 1.8.5'

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
gem 'roo', '~> 2.7.0'

# ODM support
gem 'odm', "1.0.5", :git => 'git@github.com:daveih/odm.git'
# gem "font-awesome-rails"

# SAS support
gem 'sas_xpt', :git => 'git@github.com:daveih/sas_xpt'

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
  gem 'puma', '~> 3.7'
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
