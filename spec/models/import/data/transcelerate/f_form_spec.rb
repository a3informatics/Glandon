require 'rails_helper'

describe Form do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/transcelerate"
  end

  def source_data_dir
    return "models/import/data/transcelerate/source_data"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
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
                        ?hi <http://www.assero.co.uk/ISO11179Identification#identifier> ?i
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:f, :l, :i])
    end

    def query_group(element)
      query_string = %Q{SELECT ?f ?t ?l  ?c ?n ?r ?o ?ordinal WHERE
                      {
                        #{element[:f].to_ref} <http://www.assero.co.uk/BusinessForm#hasGroup>|<http://www.assero.co.uk/BusinessForm#hasSubGroup>|<http://www.assero.co.uk/BusinessForm#hasCommon> ?f .
                        ?f <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
                        ?f <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                        ?f <http://www.assero.co.uk/BusinessForm#completion> ?c .
                        ?f <http://www.assero.co.uk/BusinessForm#note> ?n .
                        OPTIONAL{?f <http://www.assero.co.uk/BusinessForm#repeating> ?r .}
                        ?f <http://www.assero.co.uk/BusinessForm#optional> ?o .
                        ?f <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:f, :t, :l, :c, :n, :r, :o, :ordinal])
    end

    def query_items(group)
      query_string = %Q{SELECT ?i ?l ?c ?n ?o ?ordinal ?f ?mapping ?question_text ?free_text ?common_item ?has_property ?type WHERE
                      {
                        #{group[:f].to_ref} <http://www.assero.co.uk/BusinessForm#hasItem> ?i .
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
                                  ?i <http://www.assero.co.uk/BusinessForm#hasProperty> ?has_property .
                                  BIND ("BcProperty" as ?type)
                        }
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#hasCommonItem> ?common_item .
                                  BIND ("CommonItem" as ?type)
                        } 
                       
                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:i, :l, :c, :n, :o, :ordinal, :f, :mapping, :question_text, :free_text, :common_item, :has_property, :type])
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
        tc = x[:coded_value].to_s
        results << tc
      end
      results
    end

    def query_property(item)
      results = []
      query_string = %Q{SELECT ?property WHERE
                      {
                        #{item[:i].to_ref} <http://www.assero.co.uk/BusinessForm#hasProperty> ?pr .
                        ?pr <http://www.assero.co.uk/BusinessOperational#hasProperty> ?property .

                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      triples = query_results.by_object_set([:property])
      triples.each do |x|
        pr = x[:property].to_s
        results << pr
      end
      results
    end

    def query_common_item(item)
      results = []
      query_string = %Q{SELECT ?common_item WHERE
                      {
                        #{item[:i].to_ref} <http://www.assero.co.uk/BusinessForm#hasCommonItem> ?common_item .

                      }}
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      triples = query_results.by_object_set([:common_item])
      triples.each do |x|
        ci = x[:common_item].to_s
        results << ci
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
            type: params[:t].to_s,
            label: params[:l].empty? ? "" : params[:l],
            completion: params[:c].empty? ? "" : params[:c],
            optional: params[:o].empty? ? "" : params[:o],
            repeating: params[:r].empty? ? "" : params[:r],
            ordinal: params[:ordinal],
            note: params[:n].empty? ? "" : params[:n],
            items: [],
            groups: []
            }
    end

    def add_item(group, param_set)
      return if param_set.empty?
      param_set.each do |params|
        case params[:type].to_sym
              when :Question
                         item = {
                          type: params[:type].to_sym,
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
                          type: params[:type].to_sym,
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          mapping: params[:mapping]
                        }
              when :Placeholder
                      item =  {
                          type: params[:type].to_sym,
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          free_text: params[:free_text]
                        }
              when :BcProperty
                      item =  {
                          type: params[:type].to_sym,
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          has_property: query_property(params),
                          has_coded_value: query_tc(params) 
                        }
              when :CommonItem
                      item =  {
                          type: params[:type].to_sym,
                          label: params[:l].empty? ? "" : params[:l],
                          completion: params[:c].empty? ? "" : params[:c],
                          note: params[:n],
                          optional: params[:o],
                          ordinal: params[:ordinal],
                          has_common_item: query_common_item(params)
                        }
        end
        group[:items] << item
      end
      
    end

    def load_old_files
      files = 
      [
        "ACME_FN000120_1.ttl"
      ]
      files.each {|f| load_local_file_into_triple_store(source_data_dir, f)}
    end

    it "convert old" do
      results = []
      load_old_files
      forms = query_form
      forms.each do |form|
        f = add_form(form) 
        groups = query_group(form)
        groups.each_with_index do |group, i|
          g = add_group(f, group)
          add_item(g[i], query_items(group))
          sub_groups = query_group(group)
          sub_groups.each_with_index do |sub_g, j|
            sg = add_group(g[i], sub_g)
            add_item(sg[j], query_items(sub_g))
          end
        end
      results << f 
      end
      write_yaml_file(results, source_data_dir, "processed_old_form_dad.yaml")
    end

  end

end