require 'rails_helper'

describe "ISO Managed Collections", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ItemsPickerHelpers

  after :all do
    ua_destroy
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  describe "Managed Collection, curator", :type => :feature, js:true do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
      ua_create
    end

    # Tests for generic Managed Collections features here
    # it "" 

  end

  describe "Managed Collections - SDTM - BC Associations, curator", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      # load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
      ua_create
    end

    it "allows to access BC Associations page from the History Panel" 

  end 

end
