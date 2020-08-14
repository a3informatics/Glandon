require 'rails_helper'

#Latest version settings for CDISC terminology
LST_VERSION = 65
LATEST_VERSION='2020-06'

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include AuditTrailHelpers
  include ScenarioHelpers
  include QualificationUserHelpers

  describe "Load in CDISC terminology", :type => :feature do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..LST_VERSION)
      #clear_iso_concept_object
      #clear_iso_namespace_object
      #clear_iso_registration_authority_object
      #clear_iso_registration_state_object
      quh_create
      #Token.destroy_all
      #AuditTrail.destroy_all
      #clear_downloads
    end
it "Data and users loaded", scenario: true, js: true do
  end
end
