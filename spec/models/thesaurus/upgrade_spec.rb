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

    it "upgraded? I" do
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      tc_1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V58#C99079"))
      tc_2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C99079/V62#C99079"))
      item = tc_1.create_extension
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C99079E/V1#C99079E"))
      result = item.upgraded?(new_th)
      expect(result).to eq(false)
      item.upgrade(tc_2)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C99079E/V1#C99079E"))
      result = item.upgraded?(new_th)
      expect(result).to eq(true)
    end

    it "upgraded? II" do
      new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V56#TH"))
      tc_1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66767/V35#C66767"))
      tc_2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66767/V56#C66767"))
      item = tc_1.create_extension
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C66767E/V1#C66767E"))
      result = item.upgraded?(new_th)
      expect(result).to eq(false)
    end

  end

end
