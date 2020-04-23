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

    def query_group(group)
      query_string = %Q{SELECT ?f ?t ?l  ?c ?n ?r ?o ?ordinal WHERE
                      {
                        #{group[:f].to_ref} <http://www.assero.co.uk/BusinessForm#hasGroup>|<http://www.assero.co.uk/BusinessForm#hasSubGroup>|<http://www.assero.co.uk/BusinessForm#hasCommon> ?f .
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
                        OPTIONAL {
                                  ?i <http://www.assero.co.uk/BusinessForm#label_text> ?label_text .
                                  BIND ("TextLabel" as ?type)
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
        item = {
              type: params[:type].to_sym,
              label: params[:l],
              completion: params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              }
        case params[:type].to_sym
        when :Question
                  item[:mapping] = params[:mapping]
                  item[:question_text] = params[:question_text]
                  item[:has_coded_value] = query_tc(params)
        when :Mapping
                  item[:mapping] = params[:mapping]
        when :Placeholder
                  item[:free_text] = params[:free_text]
        when :BcProperty
                    item[:has_property] = query_property(params),
                    item[:has_coded_value] = query_tc(params) 
        when :CommonItem
                    item[:has_common_item] = query_common_item(params)
        end
        group[:items] << item
      end
    end

    def load_old_files
      files = ["ACME_FN000160_1.ttl"]
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
      write_yaml_file(results, source_data_dir, "processed_old_form_weight.yaml")
    end

    def normal_group?(group)
      return true if group[:type] == "http://www.assero.co.uk/BusinessForm#NormalGroup"
      return false
    end

    def new_normal_group(group)
      Form::Group::Normal.from_h({
        label: group[:label],
        completion: group[:completion],
        optional: group[:optional],
        repeating: group[:repeating],
        ordinal: group[:ordinal],
        note: group[:note]
      })
    end

    def new_common_group(group)
      Form::Group::Common.from_h({
        label: group[:label],
        completion: group[:completion],
        optional: group[:optional],
        ordinal: group[:ordinal],
        note: group[:note]
      })
    end

    def add_items(group, new_group)
      group[:items].each do |item|
        new_item = new_item(item)
        new_group.has_item << new_item
      end
    end  

    def sub_group(group, new_group)
      group[:groups].each do |sub_group|
        normal_group?(sub_group) ? sg = new_normal_group(sub_group) : sg = new_common_group(sub_group)
        add_items(sub_group, sg)
        normal_group?(sub_group) ? new_group.has_sub_group << sg : new_group.has_common << sg
        #new_group.has_sub_group << sg
      end
    end

    def new_item(params)
      item = {
              label: params[:label],
              completion: params[:completion],
              note: params[:note],
              optional: params[:optional],
              ordinal: params[:ordinal],
            }
      case params[:type].to_sym
      when :Question
                  item[:mapping] = params[:mapping]
                  item[:question_text] = params[:question_text]
                  item[:has_coded_value] = []
                  params[:has_coded_value].each_with_index do |ref, index|
                    item[:has_coded_value] << OperationalReferenceV3::TucReference.new(reference: Uri.new(uri: ref), ordinal: index+1)
                  end
                  item = Form::Item::Question.from_h(item)     
      when :Mapping
                  item[:mapping] = params[:mapping]
                  item = Form::Item::Mapping.from_h(item)
      when :Placeholder
                  item[:free_text] = params[:free_text]
                  item = Form::Item::Placeholder.from_h(item)
      when :BcProperty
                  params[:has_property].each_with_index do |ref, index|
                    item[:has_property] = OperationalReferenceV3.new(ordinal: 0, reference: Uri.new(uri: ref))
                  end
                  item[:has_coded_value] = []
                  params[:has_coded_value].each_with_index do |ref, index|
                    item[:has_coded_value] << OperationalReferenceV3::TucReference.new(reference: Uri.new(uri: ref), ordinal: index+1)
                  end
                  item = Form::Item::BcProperty.from_h(item) 
      when :CommonItem
                  params[:has_common_item].each_with_index do |ref, index|
                    item[:has_common_item] = OperationalReferenceV3.new(ordinal: 0, reference: Uri.new(uri: ref))
                  end
                  item = Form::Item::Common.from_h(item) 
      end
      item
    end  

    it "create forms" do
      results = []
      old_form = read_yaml_file(source_data_dir, "processed_old_form_alzheimers.yaml")
      old_form.each do |form|
        new_form = Form.new(label:form[:form][:label])
        form[:groups].each do |group|
          new_group = new_normal_group(group)
          new_form.has_group << new_group
          add_items(group, new_group)
          sub_group(group, new_group) if !group[:groups].empty?
        end
        new_form.set_initial(form[:form][:identifier])
        results << new_form
      end
      sparql = Sparql::Update.new
      sparql.default_namespace(results.first.uri.namespace)
      results.each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
      copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "f_alzheimers.ttl")
    end

  end

end