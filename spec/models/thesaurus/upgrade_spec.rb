require 'rails_helper'

describe "Thesaurus::Upgrade" do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include ThesauriHelpers
  include IsoManagedHelpers
  include TimeHelpers

  def sub_dir
    return "models/thesaurus/managed_concept"
  end

  def make_standard(item)
    params = {}
    params[:registration_status] = "Standard"
    params[:previous_state] = "Incomplete"
    item.update_status(params)
    puts colourize("Make standard: #{item.errors.count}", "blue")
    puts colourize("Make standard: #{item.errors.full_messages.to_sentence}", "blue") if item.errors.count > 0
  end

  describe "upgrade" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..8)
    end

    it "check extension needs to be upgraded, I" do
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V4#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V8#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V4#C67154"))
      tc_new = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V8#C67154"))
      e_old = s_th_old.add_extension(tc_old.id)
      make_standard(e_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(e_old.upgraded?(s_th_new)).to be(false)
    end

    it "check subset needs to be upgraded, I" do
      s_th_old = Thesaurus.create({ :identifier => "S TH", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V4#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V8#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V4#C67154"))
      tc_new = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V8#C67154"))
      subset_old = s_th_old.add_subset(tc_old.id)
      make_standard(subset_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(subset_old.upgraded?(s_th_new)).to be(false)
    end

    it "check subset of extension needs to be upgraded, I" do
      s_th_old = Thesaurus.create({ :identifier => "S TH2", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V4#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V8#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V4#C67154"))
      tc_new = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V8#C67154"))
      e_old = s_th_old.add_extension(tc_old.id) #add extension to old sponsor
      make_standard(e_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri) #add subsetf of extension
      subset_old = s_th_old.add_subset(e_old.id)
      make_standard(subset_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri) #make old sponsor standard
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version #create new sponsor version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(subset_old.upgraded?(s_th_new)).to be(false)
    end

    it "check extension needs to be upgraded, II" do
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V4#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V8#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V4#C67154"))
      tc_new = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V8#C67154"))
      e_old = s_th_old.add_extension(tc_old.id)
      make_standard(e_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(e_old.upgraded?(s_th_new)).to be(false)
      result = e_old.upgrade(s_th_new)
      expect(result.upgraded?(s_th_new)).to be(true)
    end

    it "check subset needs to be upgraded, II" do
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V4#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V8#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V4#C67154"))
      tc_new = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C67154/V8#C67154"))
      subset_old = s_th_old.add_subset(tc_old.id)
      make_standard(subset_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(subset_old.upgraded?(s_th_new)).to be(false)
      result = subset_old.upgrade(s_th_new)
      expect(result.upgraded?(s_th_new)).to be(true)
    end

  end

end
