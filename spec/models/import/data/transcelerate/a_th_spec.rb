require 'rails_helper'

describe "A - Transcelerate Thesaurus" do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include ThesauriHelpers
  include NameValueHelpers
  include InstallationHelpers
  
  def sub_dir
    return "models/import/data/transcelerate"
  end

  describe "hackathon" do

    def indication_cl
      cl = Thesaurus::ManagedConcept.from_h({
          label: "Indication",
          identifier: Thesaurus::ManagedConcept.new_identifier,
          definition: "An indication",
          notation: "IND"
        })
      cl.preferred_term = find_or_new_pt("Indication")
      tc_a = Thesaurus::UnmanagedConcept.from_h({
          label: "Alzheimer's Disease",
          identifier: Thesaurus::UnmanagedConcept.new_identifier,
          definition: "The Alzheimer's Disease",
          notation: "AD"
        })
      tc_a.preferred_term = find_or_new_pt("Alzheimer's Disease")
      tc_b = Thesaurus::UnmanagedConcept.from_h({
          label: "Diabetes Mellitus",
          identifier: Thesaurus::UnmanagedConcept.new_identifier,
          definition: "The Diabetes Mellitus",
          notation: "DMelli"
        })
      tc_b.preferred_term = find_or_new_pt("Diabetes Mellitus")
      tc_c = Thesaurus::UnmanagedConcept.from_h({
          label: "Rheumatoid Arthritis",
          identifier: Thesaurus::UnmanagedConcept.new_identifier,
          definition: "The Rheumatoid Arthritis",
          notation: "RArth"
        })
      tc_c.preferred_term = find_or_new_pt("Rheumatoid Arthritis")
      tc_d = Thesaurus::UnmanagedConcept.from_h({
          label: "Influenza",
          identifier: Thesaurus::UnmanagedConcept.new_identifier,
          definition: "The Influenza",
          notation: "INF"
        })
      tc_d.preferred_term = find_or_new_pt("Influenza")
      cl.narrower << tc_a
      cl.narrower << tc_b
      cl.narrower << tc_c 
      cl.narrower << tc_d 
      cl.set_initial(cl.identifier)
      cl
    end

    def add_cl(params)
      cl = Thesaurus::ManagedConcept.from_h({
          label: params[:l].empty? ? "Not Set" : params[:l],
          identifier: Thesaurus::ManagedConcept.new_identifier,
          definition: params[:d].empty? ? "Not Set" : params[:d],
          notation: params[:n]
        })
      cl.preferred_term = find_or_new_pt(params[:pt])
      cl
    end

    def add_cli(cl, param_set)
      return if param_set.empty?
      param_set.each do |params|
        cli = Thesaurus::UnmanagedConcept.from_h({
            label: params[:l].empty? ? "Not Set" : params[:l],
            identifier: Thesaurus::UnmanagedConcept.new_identifier,
            definition: params[:d].empty? ? "Not Set" : params[:d],
            notation: params[:n]
          })
        cli.preferred_term = find_or_new_pt(params[:pt])
        cl.narrower << cli
      end
    end

    def query_cl
      query_string = %Q{SELECT ?s ?d ?i ?pt ?n WHERE
{
  ?s rdf:type <http://www.assero.co.uk/ISO25964#ThesaurusConcept> .
  ?s <http://www.assero.co.uk/ISO25964#definition> ?d .
  ?s <http://www.assero.co.uk/ISO25964#notation> ?n .
  ?s <http://www.assero.co.uk/ISO25964#preferredTerm> ?pt .
  ?s <http://www.w3.org/2000/01/rdf-schema#label> ?l .
}}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:s, :d, :pt, :l, :n])
    end

    def query_cls(cl)
      query_string = %Q{SELECT ?s ?d ?i ?pt ?n WHERE
{
  #{cl[:s].to_ref} <http://www.assero.co.uk/ISO25964#hasChild> ?s .
  ?s <http://www.assero.co.uk/ISO25964#definition> ?d .
  ?s <http://www.assero.co.uk/ISO25964#notation> ?n .
  ?s <http://www.assero.co.uk/ISO25964#preferredTerm> ?pt .
  ?s <http://www.w3.org/2000/01/rdf-schema#label> ?l .
}}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:s, :d, :pt, :l, :n])
    end

    def hackathon_thesaurus(cls)
      th = Thesaurus.new
      th.label = "Thesaurus Hackathon"
      cls.each_with_index do |cl, index|
        cl.set_initial(cl.identifier)
        th.is_top_concept_reference << OperationalReferenceV3::TmcReference.from_h({reference: cl.uri, local_label: "", enabled: true, ordinal: index+1, optional: true})
        th.is_top_concept << cl.uri
      end
      th.set_initial("HACKATHON")
      th
    end

    def find_or_new_pt(label)
      results = Thesaurus::PreferredTerm.where(label: label)
      results.any? ? results.first : Thesaurus::PreferredTerm.new(label: label)
    end

    def load_old_files
      files = 
      [
        "ACME_Race Sponsor Defined_3.ttl"
      ]
      files.each {|f| load_local_file_into_triple_store(sub_dir, f)}
    end

    before :all  do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
      select_installation(:thesauri, :transcelerate)
      nv_destroy
      nv_create(parent: "1", child: "1")
    end

    it "file" do
      cls = []
      cls << indication_cl
      load_old_files
      cl_list = query_cl
      cl_list.each do |cl_params|
        cl = add_cl(cl_params)
        add_cli(cl, query_cls(cl_params))
        cls << cl
      end
      th = hackathon_thesaurus(cls)
      sparql = Sparql::Update.new
      sparql.default_namespace(th.uri.namespace)
      th.to_sparql(sparql, true)
      cls.each do |cl| 
        cl.to_sparql(sparql, true)
      end
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_thesaurus.ttl")
    end 

  end

end