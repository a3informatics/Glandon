require 'rails_helper'

describe SdtmClass do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers
  include ValidationHelpers

  def sub_dir
    return "models/sdtm_class/data"
  end

  describe "Create Class" do
    
    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")      
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")      
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("canonical_references.ttl")      
    end

    after :all do
      delete_all_public_test_files
    end

    def sdtm_to_ttl(sponsor)
      uri = sponsor.has_identifier.has_scope.uri
      sponsor.has_identifier.has_scope = uri
      uri = sponsor.has_state.by_authority.uri
      sponsor.has_state.by_authority = uri
      sponsor.to_ttl
    end

    it "create SDTM Class" do

      sdtm_model = SdtmModel.create(label: "SDTM Model Extra", identifier: "SDTM MODEL EXTRA")

      sdtm_class = SdtmClass.create(label: "SDTM Class Extra", identifier: "SDTM CLASS EXTRA")
      
      sdtm_class_variable_1 = SdtmClass::Variable.new
      sdtm_class_variable_1.label = "SDTM Class Variable 1"
      sdtm_class_variable_1.name = "--EVDTYP"
      sdtm_class_variable_1.prefixed = true
      sdtm_class_variable_1.description = "Class Variable description 1"
      sdtm_class_variable_1.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") 
      sdtm_class_variable_1.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe")
      sdtm_class_variable_1.ordinal = 1
      sdtm_class_variable_1.uri = sdtm_class_variable_1.create_uri(sdtm_model.uri)
      #sdtm_class_variable_1.is_a = Uri.new(uri: "http://www.s-cubed.dk/CAR#232daabe4ca2dfdb32645c572b1d34ddb4fe9995")
      sdtm_class_variable_1.save

      sdtm_class_variable_2 = SdtmClass::Variable.new
      sdtm_class_variable_2.label = "SDTM Class Variable 2"
      sdtm_class_variable_2.name = "--AGENT"
      sdtm_class_variable_2.prefixed = true
      sdtm_class_variable_2.description = "Class Variable description 2"
      sdtm_class_variable_2.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") 
      sdtm_class_variable_2.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe")
      sdtm_class_variable_2.ordinal = 2
      sdtm_class_variable_2.uri = sdtm_class_variable_2.create_uri(sdtm_model.uri)
      #sdtm_class_variable_2.is_a = Uri.new(uri: "http://www.s-cubed.dk/CAR#232daabe4ca2dfdb32645c572b1d34ddb4fe9995")
      sdtm_class_variable_2.save

      sdtm_class_variable_3 = SdtmClass::Variable.new
      sdtm_class_variable_3.label = "SDTM Class Variable 3"
      sdtm_class_variable_3.name = "--CONCU"
      sdtm_class_variable_3.prefixed = true
      sdtm_class_variable_3.description = "Class Variable description 3"
      sdtm_class_variable_3.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") 
      sdtm_class_variable_3.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe")
      sdtm_class_variable_3.ordinal = 3
      sdtm_class_variable_3.uri = sdtm_class_variable_3.create_uri(sdtm_model.uri)
      #sdtm_class_variable_3.is_a = Uri.new(uri: "http://www.s-cubed.dk/CAR#232daabe4ca2dfdb32645c572b1d34ddb4fe9995")
      sdtm_class_variable_3.save

      sdtm_class_variable_4 = SdtmClass::Variable.new
      sdtm_class_variable_4.label = "SDTM Class Variable 4"
      sdtm_class_variable_4.name = "--CONC"
      sdtm_class_variable_4.prefixed = true
      sdtm_class_variable_4.description = "Class Variable description 4"
      sdtm_class_variable_4.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") 
      sdtm_class_variable_4.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe")
      sdtm_class_variable_4.ordinal = 4
      sdtm_class_variable_4.uri = sdtm_class_variable_4.create_uri(sdtm_model.uri)
      #sdtm_class_variable_4.is_a = Uri.new(uri: "http://www.s-cubed.dk/CAR#232daabe4ca2dfdb32645c572b1d34ddb4fe9995")
      sdtm_class_variable_4.save

      sdtm_class_variable_5 = SdtmClass::Variable.new
      sdtm_class_variable_5.label = "SDTM Class Variable 5"
      sdtm_class_variable_5.name = "--BEATNO"
      sdtm_class_variable_5.prefixed = true
      sdtm_class_variable_5.description = "Class Variable description 5"
      sdtm_class_variable_5.typed_as = Uri.new(uri:"http://www.assero.co.uk/CSN#d2f2bbeb-8f79-4fb1-b190-dd864d29f080") 
      sdtm_class_variable_5.classified_as = Uri.new(uri:"http://www.assero.co.uk/CSN#86cd61e6-d48c-4e42-b994-bee35e2351fe")
      sdtm_class_variable_5.ordinal = 5
      sdtm_class_variable_5.uri = sdtm_class_variable_5.create_uri(sdtm_model.uri)
      #sdtm_class_variable_5.is_a = Uri.new(uri: "http://www.s-cubed.dk/CAR#232daabe4ca2dfdb32645c572b1d34ddb4fe9995")
      sdtm_class_variable_5.save

      sdtm_class.includes_column = [sdtm_class_variable_1, sdtm_class_variable_2, sdtm_class_variable_3, sdtm_class_variable_4, sdtm_class_variable_5]
      sdtm_class.save
      sdtm_class = SdtmClass.find_full(sdtm_class.uri)
    
      full_path = sdtm_to_ttl(sdtm_class)
      full_path = sdtm_class.to_ttl
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "SDTM_Class_extra.ttl")
    end
  
  end

end