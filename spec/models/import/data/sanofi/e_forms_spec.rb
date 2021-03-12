require 'rails_helper'

describe "E - ZDUMMYMED Protocol" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/sanofi"
  end

  before :all do
    IsoHelpers.clear_cache
    clear_triple_store    
    load_local_file_into_triple_store(sub_dir, "sanofi_protocol_base_2.nq.gz")
    test_query # Make sure any loading has finished.
    load_schema_file_into_triple_store("protocol.ttl")
    load_schema_file_into_triple_store("enumerated.ttl")
    load_schema
  end

  after :all do
    #
  end

  before :each do
    #
  end

  after :each do
    delete_all_public_test_files
  end

  def new_form(identifier, label)
    object = Form.new(identifier: identifier, label: label)
    object.set_initial(identifier)
    object.creation_date = object.last_change_date
    object
  end

  describe "Dummy Forms" do

    it "Protocol" do
      form_items =
      [
        new_form("INFORMED CONSENT DEMO", "Informed Consent"),
        new_form("DM DEMO", "Demographics"),
        new_form("LB DEMO", "Routine Laboratory"),
        new_form("RANDOM DEMO", "Randomization"),
        new_form("X_OVER DEMO", "Cross-Over | Swap"),
        new_form("AE DEMO", "Adverse Events"),
        new_form("TERMINATION DEMO", "Termination Record"),
        new_form("DEVICE ALLOC DEMO", "Device Allocation"),
        new_form("CGM RUNNING DEMO", "CGM Running")
      ]

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(form_items.first.uri.namespace)
      form_items.each {|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "e_forms.ttl")
    end

  end

end
