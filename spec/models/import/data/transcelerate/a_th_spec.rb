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

  def source_data_dir
    return "models/import/data/transcelerate/source_data"
  end

  describe "hackathon" do

    def build_cls_data
      # Only add at the end. Prserves identifiers
      [
        {  
          cl:
          { 
            label: "Indication",
            identifier: Thesaurus::ManagedConcept.new_identifier,
            definition: "An indication",
            notation: "IND",
            preferred_term: "Indication"
          },
          cli:
          [
            {
              label: "Alzheimer's Disease",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "The Alzheimer's Disease",
              notation: "AD",
              preferred_term: "Alzheimer's Disease"
            }, 
            {
              label: "Diabetes Mellitus",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "The Diabetes Mellitus",
              notation: "DMelli",
              preferred_term: "Diabetes Mellitus"
            },
            {
            label: "Rheumatoid Arthritis",
            identifier: Thesaurus::UnmanagedConcept.new_identifier,
            definition: "The Rheumatoid Arthritis",
            notation: "RArth",
            preferred_term: "Rheumatoid Arthritis"
            },
            {
              label: "Influenza",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "The Influenza",
              notation: "INF",
              preferred_term: "Influenza"
            }
          ]
        },
        {  
          cl:
          {
            label: "Demographic Test Codes",
            identifier: Thesaurus::ManagedConcept.new_identifier,
            definition: "The test codes required for the demographic data.",
            notation: "DMTESTCD",
            preferred_term: "Demographic Test Codes"
          },
          cli:
          [
            {
              label: "Age",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Age",
              notation: "AGE",
              preferred_term: "Age Test"
            },
            {
              label: "Race",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Race",
              notation: "RACE",
              preferred_term: "Race Test"
            },
            {
              label: "Ethnicity",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Ethnicity",
              notation: "ETHNICITY",
              preferred_term: "Ethnicity"
            },
            {
              label: "Sex",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Sex",
              notation: "SEX",
              preferred_term: "Sex"
            }
          ]
        },
        {
          cl:
          {
            label: "Disability Assessment For Dementia (DAD) Subcategory",
            identifier: Thesaurus::ManagedConcept.new_identifier,
            definition: "Disability Assessment For Dementia (DAD) Subcategory",
            notation: "DAD SCAT",
            preferred_term: "Disability Assessment For Dementia (DAD) Subcategory"
          },
          cli:
          [
            {
              label: "Hygiene",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Hygiene",
              notation: "HYGIENE",
              preferred_term: "Hygiene"
            },
            {
              label: "Dressing",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Dressing",
              notation: "DRESSING",
              preferred_term: "Dressing"
            },
            {
              label: "Continence",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Continence",
              notation: "CONTINENCE",
              preferred_term: "Continence"
            },
            {
              label: "Eating",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Eating",
              notation: "EATING",
              preferred_term: "Eating"
            },
            {
              label: "Meal Preparation",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Meal Preparation",
              notation: "MEAL PREPARATION",
              preferred_term: "Meal Preparation"
            },
            {
              label: "Telephoning",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Telephoning",
              notation: "TELEPHONING",
              preferred_term: "Telephoning"
            },
            {
              label: "Going on an Outing",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Going on an Outing",
              notation: "GOING ON AN OUTING",
              preferred_term: "Going on an Outing"
            },
            {
              label: "Finance and Correspondence",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Finance and Correspondence",
              notation: "FINANCE AND CORRESPONDENCE",
              preferred_term: "Finance and Correspondence"
            },
            {
              label: "Medications",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Medications",
              notation: "MEDICATIONS",
              preferred_term: "Medications"
            },
            {
              label: "Leisure and Housework",
              identifier: Thesaurus::UnmanagedConcept.new_identifier,
              definition: "Leisure and Housework",
              notation: "LEISURE AND HOUSEWORK",
              preferred_term: "Leisure and Housework"
            }
          ]
        }
      ]
    end

    def build_cls
      results = []
      build_cls_data.each do |cl_params|
        cl = Thesaurus::ManagedConcept.new(cl_params[:cl])
        cl.preferred_term = find_or_new_pt(cl_params[:cl][:preferred_term])
        cl_params[:cli].each do |cli_params|
          cli = Thesaurus::UnmanagedConcept.new(cli_params)
          cli.preferred_term = find_or_new_pt(cli_params[:preferred_term])
          cl.narrower << cli
        end
        cl.set_initial(cl.identifier)
        results << cl
      end
      results
    end

    def add_cl(params)
      { cl:
        {
          label: params[:l].empty? ? "Not Set" : params[:l],
          identifier: Thesaurus::ManagedConcept.new_identifier,
          definition: params[:d].empty? ? "Not Set" : params[:d],
          notation: params[:n],
          preferred_term: params[:pt]
        },
        cli: []
      }
    end

    def add_cli(cl, param_set)
      return if param_set.empty?
      param_set.each do |params|
        cl[:cli] << {
          label: params[:l].empty? ? "Not Set" : params[:l],
          identifier: Thesaurus::UnmanagedConcept.new_identifier,
          definition: params[:d].empty? ? "Not Set" : params[:d],
          notation: params[:n], 
          preferred_term: params[:pt]
        }
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
      th.set_initial("CT")
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
      files.each {|f| load_local_file_into_triple_store(source_data_dir, f)}
    end

    before :all  do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      select_installation(:thesauri, :transcelerate)
      nv_destroy
      nv_create(parent: "1", child: "1")
    end

    it "convert old" do
      results = []
      load_old_files
      cl_list = query_cl
      cl_list.each do |cl_item|
        cl = add_cl(cl_item)
        add_cli(cl, query_cls(cl_item))
        results << cl
      end
      write_yaml_file(results, source_data_dir, "processed_old_thesaurus.yaml")
    end

    it "file" do
      cls = build_cls
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