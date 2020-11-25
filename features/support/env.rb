# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'capybara/RSpec'
require 'cucumber/rails'
require 'capybara/cucumber'
require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'
require 'allure-cucumber'
require 'rspec/expectations'
require 'rspec'
require 'base64'
require 'selenium-webdriver'
require 'nokogiri'
require 'watir'

# Load the schema. This is so it is available at class load/elaboration
#require Rails.root.join('spec/support/data_helpers.rb')
#include DataHelpers
#load_files(schema_files, [])


Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
#include NameValueHelpers
#Latest version settings for CDISC terminology


include NameValueHelpers
include PauseHelpers
include DataHelpers
include UiHelpers
include WaitForAjaxHelper
include DownloadHelpers
include AuditTrailHelpers
include ScenarioHelpers
include QualificationUserHelpers
include EditorHelpers
include ItemsPickerHelpers

Cucumber::Rails::Database.autorun_database_cleaner = false
#DatabaseCleaner.strategy = :truncation
#Cucumber::Rails::Database.javascript_strategy = :truncation
 
#ENVIRONMENT = 'TEST'

ENVIRONMENT = 'VAL'

#ENVIRONMENT = 'REMOTE_TEST'

if ENVIRONMENT == 'VAL' 
RemoteServerHelpers.switch_to_remote
end

if ENVIRONMENT == 'REMOTE_TEST' 
RemoteServerHelpers.switch_to_remote_test
end

if ENVIRONMENT == 'TEST' 
RemoteServerHelpers.switch_to_local


Before do
  log('Clean databse')
 # DatabaseCleaner.clean
  nv_destroy
  nv_create(parent: "10", child: "999")

  LST_VERSION = 65
  LATEST_VERSION='2020-06'
  #Load in the CDISC Terminology and recreate users
    log('loading terminology and users')
    load_files(schema_files, [])
    
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_test_file_into_triple_store("forms/FN000150.ttl")
    load_data_file_into_triple_store("biomedical_concept_templates.ttl")
    #load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    #full_path = Rails.root.join("db/load/")
    #load_file_into_triple_store(full_path)
    load_data_file_into_triple_store("complex_datatypes.ttl")
    #load_data_file_into_triple_store("mdr_sponsor_one_identification.ttl")
    #load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    #load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    #load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    #load_data_file_into_triple_store("sponsor_one/custom_property/custom_properties.ttl")
    #load_data_file_into_triple_store("sponsor_one/ct/CT_V2-6.ttl")
    load_cdisc_term_versions(1..LST_VERSION)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    #quh_destroy
    quh_create
    Token.destroy_all
    AuditTrail.destroy_all
    clear_downloads

    log('Data and users loaded')
end

After do |scenario|
  nv_destroy
end
end


 #TURN_ON_SCREEN_SHOT=false
 TURN_ON_SCREEN_SHOT=true

 TYPE ='Expected'

Capybara::Screenshot.autosave_on_failure = false
Capybara::Screenshot.append_timestamp = false
Capybara.default_driver = :selenium_chrome

# Keep only the screenshots generated from the last failing test suite
#Capybara::Screenshot.prune_strategy = :keep_last_run

# Keep up to the number of screenshots specified in the hash
#Capybara::Screenshot.prune_strategy = { keep: 2}

if TYPE == 'Actual' 
  Capybara::save_path = "./cucumber-report/screenshots/actual/"
  # Clean out the screenshot folder before run
  FileUtils.rm_rf(Dir[Capybara::save_path])
else
  Capybara::save_path = "./cucumber-report/screenshots/expected/"
  # Clean out the screenshot folder before run
  FileUtils.rm_rf(Dir[Capybara::save_path])
end

def zoom_in
  page.execute_script("document.body.style.zoom='100%'")
end

def zoom_out
  page.execute_script("document.body.style.zoom='75%'")
end

def save_screen(e_or_a,screen_shot_enabled=TURN_ON_SCREEN_SHOT)

  if screen_shot_enabled
     Capybara.current_session.current_window.maximize
     zoom_out
     screenshot_file_name = "#{Time.now.strftime("#{e_or_a}_%d_%m_%Y__%H_%M_%S")}.png" 
     save_screenshot(screenshot_file_name, :full => true)
     screenshot_path = Capybara::save_path+screenshot_file_name
     attach(File.open(screenshot_path), "image/png")
     #attach(screenshot_path, "image/png")
     zoom_in
    end
end

# frozen_string_literal: true

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
# begin
# DatabaseCleaner.strategy = :transaction
# rescue NameError
# raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
# end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { except: [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('not @no-txn', 'not @selenium', 'not @culerity', 'not @celerity', 'not @javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
 #Cucumber::Rails::Database.javascript_strategy = :truncation
 #Cucumber::Rails::Database.javascript_strategy = :transaction






 
