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

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
    end

    it "check extension needs to be upgraded, I" do
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V43#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V46#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C115304/V43#C115304"))
      tc_new = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C115304/V46#C115304"))
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
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V32#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V38#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      tc_new = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V38#C99079"))
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
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V32#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V40#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C100129/V32#C100129"))
      tc_new = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C100129/V40#C100129"))
      

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
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V43#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V46#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C115304/V43#C115304"))
      tc_new = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C115304/V46#C115304"))
      e_old = s_th_old.add_extension(tc_old.id)
      make_standard(e_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(e_old.upgraded?(s_th_new)).to be(false)
      e_old.upgrade(s_th_new)
      e_old = Thesaurus::ManagedConcept.find_minimum(e_old.uri)
      expect(e_old.upgraded?(s_th_new)).to be(true)
    end

    it "check subset needs to be upgraded, II" do
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V43#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V46#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C115304/V43#C115304"))
      tc_new = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C115304/V46#C115304"))
      subset_old = s_th_old.add_subset(tc_old.id)
      make_standard(subset_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      expect(subset_old.upgraded?(s_th_new)).to be(false)
      subset_old.upgrade(s_th_new)
      subset_old = Thesaurus::ManagedConcept.find_minimum(subset_old.uri)
      expect(subset_old.upgraded?(s_th_new)).to be(true)
    end

  end

end
