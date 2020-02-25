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

  describe "upgrade" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      #load_data_file_into_triple_store("mdr_identification.ttl")
      #load_data_file_into_triple_store("thesaurus_sponsor5_impact.ttl")
      #load_data_file_into_triple_store("thesaurus_sponsor6_impact.ttl")
    end

    it "check extension needs to be upgraded, I" do
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      tc_55 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C115304/V43#C115304"))
      tc_61 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C115304/V46#C115304"))
      e_old = tc_55.create_extension
      s_th_old.add_extension(e_old.id)
      params = {}
      params[:registration_status] = "Qualified"
      params[:previous_state] = "Incomplete"
  byebug      
      s_th_old.update_status(params)
      s_th_new = s_th_old.create_next_version

      e_old.upgraded?(s_th_new)
    end

    # it "have I been upgraded? I" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V56#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/NP000123P/V1#NP000123P"))
    #   result = tc.have_i_been_upgraded?(new_th)
    #   expect(result).to eq(true)
    # end

    # it "have I been upgraded? II" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V55#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/NP000123P/V1#NP000123P"))
    #   result = tc.have_i_been_upgraded?(new_th)
    #   expect(result).to eq(false)
    # end

    # it "have I been upgraded? III" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V35#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C66767/V1#C66767"))
    #   result = tc.have_i_been_upgraded?(new_th)
    #   expect(result).to eq(false)
    # end

    # it "have I been upgraded? IV" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V55#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C66767/V1#C66767"))
    #   result = tc.have_i_been_upgraded?(new_th)
    #   expect(result).to eq(false)
    # end

    # it "have I been upgraded? V" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C66767/V1#C66767"))
    #   result = tc.have_i_been_upgraded?(new_th)
    #   expect(result).to eq(true)
    # end

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

    # it "upgrade? I" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C66767/V1#C66767"))
    #   source = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66767/V35#C66767"))
    #   result = tc.upgrade?(source.id, new_th)
    #   expect(result).to eq({:errors=>"Item already upgraded", :upgrade=> false})
    # end

    # it "upgrade? II" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V55#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/C66767/V1#C66767"))
    #   source = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66767/V35#C66767"))
    #   result = tc.upgrade?(source.id, new_th)
    #   expect(result).to eq({:errors=>"", :upgrade=>true})
    # end

    # it "upgrade? III" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/NP000123P/V1#NP000123P"))
    #   source = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66767/V35#C66767"))
    #   result = tc.upgrade?(source.id, new_th)
    #   expect(result).to eq({:errors=>"Item already upgraded", :upgrade=>false})
    # end

    # it "upgrade? IV" do
    #   new_th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V55#TH"))
    #   tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.s-cubed.dk/NP000123P/V1#NP000123P"))
    #   source = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66767/V35#C66767"))
    #   result = tc.upgrade?(source.id, new_th)
    #   expect(result).to eq({upgrade: false, errors: "Cannot upgrade. You must first upgrade Code List: C66767"})
    # end

  end

end
