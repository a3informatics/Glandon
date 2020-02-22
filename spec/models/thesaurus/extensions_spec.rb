require 'rails_helper'

describe "Thesaurus::Extensions" do

  include DataHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus/extensions"
  end

  describe "Extend Extensible Code List Checks" do

    it "can extend unextensible, true" do
      local_configuration = {can_extend_unextensible: true}
      expect(Thesaurus::ManagedConcept).to receive(:extensions_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.can_extend_unextensible?).to eq(true)
    end

    it "can extend unextensible, false" do
      local_configuration = {can_extend_unextensible: false}
      expect(Thesaurus::ManagedConcept).to receive(:extensions_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.can_extend_unextensible?).to eq(false)
    end

  end    

  describe "Code List Type Checks" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
    end

    it "determines if code list extended and finds the URIs" do
      tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00002/V1#A00002"))
      expect(tc1.extended?).to eq(false)
      expect(tc2.extended?).to eq(false)
      expect(tc1.extension?).to eq(false)
      expect(tc2.extension?).to eq(false)
      sparql = %Q{INSERT DATA { #{tc2.uri.to_ref} th:extends #{tc1.uri.to_ref} }}
      Sparql::Update.new.sparql_update(sparql, "", [:th])
      expect(tc1.extended?).to eq(true)
      expect(tc2.extended?).to eq(false)
      expect(tc1.extension?).to eq(false)
      expect(tc2.extension?).to eq(true)
      expect(tc1.extended_by).to eq(tc2.uri)
      expect(tc1.extension_of).to eq(nil)
      expect(tc2.extension_of).to eq(tc1.uri)
      expect(tc2.extended_by).to eq(nil)
    end

  end

  describe "Extensible Code List Checks" do
  
    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..45)
    end

    def a_tc(identifier)
      tc = Thesaurus::ManagedConcept.from_h({
        label: "Extension",
        identifier: identifier,
        definition: "A definition",
        notation: identifier
      })
      tc.set_initial(identifier)
      tc.save
    end

    it "can upgrade an extension" do
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      item_1 = tc_32.create_extension
      item_1 = Thesaurus::ManagedConcept.find(item_1.uri)
      expect(item_1.narrower.count).to eq(7)
      check_dates(item_1, sub_dir, "upgrade_expected_1a.yaml", :last_change_date)
      check_file_actual_expected(item_1.to_h, sub_dir, "upgrade_expected_1a.yaml", equate_method: :hash_equal)
      item_2 = item_1.upgrade(tc_34)
      item_2 = Thesaurus::ManagedConcept.find(item_2.uri)
      expect(item_2.narrower.count).to eq(8)
      check_file_actual_expected(item_2.to_h, sub_dir, "upgrade_expected_1b.yaml", equate_method: :hash_equal)
      item_3 = item_1.upgrade(tc_45)
      item_3 = Thesaurus::ManagedConcept.find(item_3.uri)
      expect(item_3.narrower.count).to eq(10)
      check_file_actual_expected(item_3.to_h, sub_dir, "upgrade_expected_1c.yaml", equate_method: :hash_equal)
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      expect(tc_32.narrower.count).to eq(7)
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      expect(tc_34.narrower.count).to eq(8)
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      expect(tc_45.narrower.count).to eq(10)
    end

    it "can upgrade an extension with extension" do
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      item_1 = tc_32.create_extension
      item_1 = Thesaurus::ManagedConcept.find(item_1.uri)
      expect(item_1.narrower.count).to eq(7)
      check_dates(item_1, sub_dir, "upgrade_expected_2a.yaml", :last_change_date)
      check_file_actual_expected(item_1.to_h, sub_dir, "upgrade_expected_2a.yaml", equate_method: :hash_equal)
      item_1.narrower_push a_tc("A1")
      expect(item_1.narrower.count).to eq(8)
      item_1.save
      item_2 = item_1.upgrade(tc_34)
      item_2 = Thesaurus::ManagedConcept.find(item_2.uri)
      expect(item_2.narrower.count).to eq(9)
      check_file_actual_expected(item_2.to_h, sub_dir, "upgrade_expected_2b.yaml", equate_method: :hash_equal)
      item_2.narrower_push a_tc("A2")
      item_2.save
      item_3 = item_1.upgrade(tc_45)
      item_3 = Thesaurus::ManagedConcept.find(item_3.uri)
      expect(item_3.narrower.count).to eq(12)
      check_file_actual_expected(item_3.to_h, sub_dir, "upgrade_expected_2c.yaml", equate_method: :hash_equal)
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      expect(tc_32.narrower.count).to eq(7)
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      expect(tc_34.narrower.count).to eq(8)
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      expect(tc_45.narrower.count).to eq(10)
   end

    it "cannot upgrade non extension" do
      tc_32 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      tc_34 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V34#C99079"))
      tc_45 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V45#C99079"))
      expect{tc_32.upgrade(tc_34)}.to raise_error(Errors::ApplicationLogicError, "Only Subsets or Extensions can be upgraded.")
    end

  end

end
