require 'rails_helper'

describe Endpoint do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/endpoint/data"
  end

  describe "Create Endpoint" do
    
    before :all do
      data_files = ["parameter.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")     
    end

    after :all do
      delete_all_public_test_files
    end

    def item_to_ttl(item)
      uri = item.has_identifier.has_scope.uri
      item.has_identifier.has_scope = uri
      uri = item.has_state.by_authority.uri
      item.has_state.by_authority = uri
      item.to_ttl
    end

  #   it "create Endpoint" do
  #     endpoint = Endpoint.create(identifier: "END1", label: "Endpoint 1", full_text: "[[[Timepoint]]][[[Param]]]")
  #     endpoint = Endpoint.find_minimum(endpoint.uri)
  #     parameter1 = Parameter.
  #     parameter2 = Parameter.
  #     endpoint.has_parameter = [parameter1, parameter2]
  #     endpoint.save
  #     full_path = item_to_ttl(endpoint)
  #     full_path = endpoint.to_ttl
  # copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "endpoint.ttl")
  #   end

    it "End Points" do
      parameter1 = Parameter.where(label: "BC").first
      parameter2 = Parameter.where(label: "Intervention").first
      parameter3 = Parameter.where(label: "Timepoint").first
      parameter4 = Parameter.where(label: "Assessment").first
  
      endpoints =
      [
        {
          label: "Endpoint 1",
          full_text: "[[[Timepoint]]][[[AnalysisConcept]]]",
          has_parameter: [parameter3]
        },
        {
          label: "Endpoint 2",
          full_text: "[[[Timepoint]]][[[AnalysisConcept]]]",
          has_parameter: [parameter3]
        },
        {
          label: "Endpoint 3",
          full_text: "[[[Timepoint]]][[[AnalysisConcept]]]",
          has_parameter: [parameter3]
        },
        {
          label: "Endpoint 4",
          full_text: "[[[BC]]] at baseline then every [[[Timepoint-freq]]] during the first [[[Timepoint-span]]] then at [[[Timepoint]]] and every [[[Timepoint-freq]]] until [[[Timepoint]]]",
          has_parameter: [parameter1, parameter3]
        }
        #,
        # {
        #   label: "Endpoint 5",
        #   full_text: "Clinical laboratory tests (including [[[Assessment]]]), [[[Assessment]]], and [[[Assessment]]]"
        # },
        # {
        #   label: "Endpoint 6",
        #   full_text: "The change from baseline to [[[Timepoint]]] in continuous laboratory tests: Hepatic Function Panel"
        # },
        # {
        #   label: "Endpoint 7",
        #   full_text: "The proportion of participants with abnormal (high or low) laboratory measures (urinalysis) during the postrandomization phase"
        # },
        # {
        #   label: "Endpoint 8",
        #   full_text: "The change from baseline to [[[Timepoint]]] in ECG parameter: QTcF"
        # },
        # {
        #   label: "Endpoint 9",
        #   full_text: "The change from baseline to [[[Timepoint]]] in the [[[Assessment]]]"
        # }
      ]
      items = []
      endpoints.each_with_index do |ep, index|
        item = Endpoint.new(ep)
        item.set_initial("EP #{index+1}")
        items << item
      end
      sparql = Sparql::Update.new
      sparql.default_namespace(items.first.uri.namespace)
      items.each {|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "endpoints.ttl")
    end
  
  end

end