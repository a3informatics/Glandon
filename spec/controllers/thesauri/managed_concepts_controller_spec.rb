require 'rails_helper'

describe Thesauri::ManagedConceptsController do

  include DataHelpers
  
  def sub_dir
    return "controllers/thesauri/managed_concept"
  end

  describe "Authorized User" do
  	
    login_curator

    before :each do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
      ]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "changes" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_count).and_return(5)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:forward_backward).and_return({start: nil, end: Uri.new(uri: "http://www.xxx.com/aaa#1")})
      get :changes, id: "aaa"
      expect(assigns(:links)).to eq({start: "", end: "/thesauri/managed_concepts/aHR0cDovL3d3dy54eHguY29tL2FhYSMx/changes"})
      expect(response).to render_template("changes")
    end

  end
  
end