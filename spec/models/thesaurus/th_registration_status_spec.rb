require 'rails_helper'

describe Thesaurus::McRegistrationStatus do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include CustomPropertyHelpers
  include ThesaurusManagedConceptFactory
  include NameValueHelpers
  include IsoManagedHelpers

	def sub_dir
    return "models/thesaurus/th_registration_status"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_sponsor_5_state.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "managed children states" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = thesaurus.managed_children_states
      check_file_actual_expected(actual, sub_dir, "states_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update status permitted" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/STATE/V1#TH"))
      expect(thesaurus.update_status_permitted?).to eq(false)
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      IsoManagedHelpers.make_item_candidate(tc)
      expect(thesaurus.update_status_permitted?).to eq(true)
      IsoManagedHelpers.make_item_recorded(tc)
      expect(thesaurus.update_status_permitted?).to eq(true)
      IsoManagedHelpers.make_item_recorded(thesaurus)
      expect(thesaurus.update_status_permitted?).to eq(false)
      IsoManagedHelpers.make_item_qualified(tc)
      expect(thesaurus.update_status_permitted?).to eq(true)
      IsoManagedHelpers.make_item_qualified(thesaurus)
      expect(thesaurus.update_status_permitted?).to eq(false)
      IsoManagedHelpers.make_item_standard(tc)
      expect(thesaurus.update_status_permitted?).to eq(true)
      IsoManagedHelpers.make_item_standard(thesaurus)
      expect(thesaurus.update_status_permitted?).to eq(false)
    end

    it "update status not permitted, error message" do
      thesaurus = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/STATE/V1#TH"))
      expect(thesaurus.update_status_permitted?).to eq(false)
      expect(thesaurus.errors.count).to eq(1)
      expect(thesaurus.errors.full_messages).to eq(['Child items are not in the appropriate state'])
    end

  end

end
