require 'rails_helper'

describe Form do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers
  include ValidationHelpers

  def sub_dir
    return "models/import/data/transcelerate"
  end

  def source_data_dir
    return "models/import/data/transcelerate/source_data"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    #load_cdisc_term_versions(1..62)
    load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Convert old forms" do

    def query_form
      query_string = %Q{SELECT ?f ?l ?i WHERE
                      {
                        ?f rdf:type <http://www.assero.co.uk/BusinessForm#Form> .
                        ?f <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                        ?f <http://www.assero.co.uk/ISO11179Identification#hasIdentifier> ?hi .
                        ?f <http://www.assero.co.uk/ISO11179Registration#hasState> ?hs .
                        ?hi <http://www.assero.co.uk/ISO11179Identification#identifier> ?i
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:f, :l, :i])
    end

    def query_group(form)
      query_string = %Q{SELECT ?g ?t ?l  ?c ?n ?r ?o ?ordinal WHERE
                      {
                        #{form[:f].to_ref} <http://www.assero.co.uk/BusinessForm#hasGroup> ?g .
                        ?g <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
                        ?g <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                        ?g <http://www.assero.co.uk/BusinessForm#completion> ?c .
                        ?g <http://www.assero.co.uk/BusinessForm#note> ?n .
                        ?g <http://www.assero.co.uk/BusinessForm#repeating> ?r .
                        ?g <http://www.assero.co.uk/BusinessForm#optional> ?o .
                        ?g <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:g, :t, :l, :c, :n, :r, :o, :ordinal])
    end

    def query_sub_group(group)
      query_string = %Q{SELECT ?sg ?t ?l ?c ?n ?r ?o ?ordinal WHERE
                      {
                        #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasSubGroup> ?sg  .
                        ?sg <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
                        ?sg <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                        ?sg <http://www.assero.co.uk/BusinessForm#completion> ?c .
                        ?sg <http://www.assero.co.uk/BusinessForm#note> ?n .
                        ?sg <http://www.assero.co.uk/BusinessForm#repeating> ?r .
                        ?sg <http://www.assero.co.uk/BusinessForm#optional> ?o .
                        ?sg <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      query_results.by_object_set([:sg, :t, :l, :c, :n, :r, :o, :ordinal])
    end

    def query_common(group)
      query_string = %Q{SELECT ?g ?t ?l ?c ?n ?r ?o ?ordinal WHERE
                      {
                        #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasCommon> ?g  .
                        ?g <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
                        ?g <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                        ?g <http://www.assero.co.uk/BusinessForm#completion> ?c .
                        ?g <http://www.assero.co.uk/BusinessForm#note> ?n .
                        ?g <http://www.assero.co.uk/BusinessForm#repeating> ?r .
                        ?g <http://www.assero.co.uk/BusinessForm#optional> ?o .
                        ?g <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      query_results.by_object_set([:g, :t, :l, :c, :n, :r, :o, :ordinal])
    end

    def query_items(group)
      results = [{}]
      query_string = %Q{SELECT ?i ?l ?c ?n ?o ?ordinal ?f ?mapping ?question_text  ?free_text ?common_item ?type WHERE
                      {
                        #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasItem> ?i .
                        ?i <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                        ?i <http://www.assero.co.uk/BusinessForm#completion> ?c .
                        ?i <http://www.assero.co.uk/BusinessForm#note> ?n .
                        ?i <http://www.assero.co.uk/BusinessForm#optional> ?o .
                        ?i <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#format> ?f .
                                  ?i <http://www.assero.co.uk/BusinessForm#mapping> ?mapping .
                                  ?i <http://www.assero.co.uk/BusinessForm#question_text> ?question_text .
                                  BIND ("Question" as ?type)
                        }
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#mapping> ?mapping .
                                  BIND ("Mapping" as ?type)
                        }
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#free_text> ?free_text .
                                  BIND ("Placeholder" as ?type)
                        }
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#has_property> ?has_property .
                                  
                                  BIND ("BcProperty" as ?type)
                        }
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#hasCommonItem> ?common_item .
                                  BIND ("CommonItem" as ?type)
                        } 
                       
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:i, :l, :c, :n, :o, :ordinal, :f, :mapping, :question_text, :free_text, :common_item, :type])
    end

    def query_tc(item)
      results = []
      query_string = %Q{SELECT ?coded_value WHERE
                      {
                        #{item[:i].to_ref} <http://www.assero.co.uk/BusinessForm#hasThesaurusConcept> ?tc .
                        ?tc <http://www.assero.co.uk/BusinessOperational#hasThesaurusConcept> ?coded_value .
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      triples = query_results.by_object_set([:coded_value])
      triples.each do |x|
        tc = x[:coded_value].to_ref
        results << tc
      end
      results
    end

    def add_form(params)
      { form:
        {
          label: params[:l].empty? ? "Not Set" : params[:l],
          identifier: params[:i]
        },
        groups: []
      }
    end

    def add_group(form, params)
        form[:groups] << {
            label: params[:l].empty? ? "" : params[:l],
            completion: params[:c].empty? ? "" : params[:c],
            optional: params[:o].empty? ? "" : params[:o],
            repeating: params[:r].empty? ? "" : params[:r],
            ordinal: params[:ordinal],
            note: params[:n].empty? ? "" : params[:n],
            items: [],
            sub_groups: []
            }
    end

    # def add_sub_group(group, params)
    #     group[:sub_groups] << {
    #       label: params[:l].empty? ? "" : params[:l],
    #       completion: params[:c].empty? ? "" : params[:c],
    #       optional: params[:o].empty? ? "" : params[:o],
    #       repeating: params[:r].empty? ? "" : params[:r],
    #       ordinal: params[:ordinal],
    #       note: params[:n].empty? ? "" : params[:n],
    #       items: []
    #     }
    # end

    def add_item(group, param_set)
      return if param_set.empty?
      param_set.each do |params|
        case params[:type].to_sym
              when :Question
                         item = {
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          mapping: params[:mapping],
                          question_text: params[:question_text],
                          has_coded_value: query_tc(params)
                          }
              when :Mapping
                       item = {
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          mapping: params[:mapping]
                        }
              when :Placeholder
                      item =  {
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          free_text: params[:free_text]
                        }
        end
        group[:items] << item
      end
      
    end

    def load_old_files
      files = 
      [
        "ACME_FN000150_1.ttl", "ACME_FN000160_1.ttl"
      ]
      files.each {|f| load_local_file_into_triple_store(source_data_dir, f)}
    end

    it "convert old" do
      results = []
      load_old_files
      forms = query_form
      forms.each do |form|
        f = add_form(form) 
        query_group(form).each_with_index do |group, i|
          g = add_group(f, group)
          add_item(g[i], query_items(group))
          # if !query_sub_group(group).empty?
          #   query_sub_group(group).each_with_index do |sub_group, i|
          #     sg = add_sub_group(g[i], group)
          #     add_item(sg[i], query_items(sub_group))
          #   end
          # end
        end
        results << f 
      end 
      write_yaml_file(results, source_data_dir, "processed_old_forms.yaml")
    end

  end

end