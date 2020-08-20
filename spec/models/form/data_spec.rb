require 'rails_helper'

describe Form do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers
  include ValidationHelpers

  def sub_dir
    return "models/form/data"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    load_cdisc_term_versions(1..65)
    load_data_file_into_triple_store("mdr_identification.ttl")
    @ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V65#TH"))
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Convert old forms" do

    def query_form
      query_string = %Q{
        SELECT ?f ?l ?i ?scope ?v ?sv ?auth ?reg WHERE
        {
          ?f rdf:type <http://www.assero.co.uk/BusinessForm#Form> .
          ?f <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?f <http://www.assero.co.uk/ISO11179Identification#hasIdentifier> ?hi .
          ?f <http://www.assero.co.uk/ISO11179Registration#hasState> ?hs .
          ?hi <http://www.assero.co.uk/ISO11179Identification#identifier> ?i .
          ?hi <http://www.assero.co.uk/ISO11179Identification#hasScope> ?scope .
          ?hi <http://www.assero.co.uk/ISO11179Identification#version> ?v .
          ?hi <http://www.assero.co.uk/ISO11179Identification#semantic_version> ?sv .
          ?hs <http://www.assero.co.uk/ISO11179Registration#byAuthority> ?auth .
          ?hs <http://www.assero.co.uk/ISO11179Registration#registrationStatus> ?reg .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:f, :l, :i, :scope, :v, :sv, :auth, :reg])
    end

    def query_group(form)
      query_string = %Q{
        SELECT ?g ?t ?l  ?c ?n ?r ?o ?ordinal WHERE
        {
          #{form[:f].to_ref} <http://www.assero.co.uk/BusinessForm#hasGroup> ?g .
          ?g <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
          ?g <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?g <http://www.assero.co.uk/BusinessForm#completion> ?c .
          ?g <http://www.assero.co.uk/BusinessForm#note> ?n .
          ?g <http://www.assero.co.uk/BusinessForm#repeating> ?r .
          ?g <http://www.assero.co.uk/BusinessForm#optional> ?o .
          ?g <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:g, :t, :l, :c, :n, :r, :o, :ordinal])
    end

    def query_sub_group(group)
      query_string = %Q{
        SELECT ?g ?t ?l ?c ?n ?r ?o ?ordinal WHERE
        {
          #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasSubGroup> ?sg  .
          ?sg <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
          ?sg <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?sg <http://www.assero.co.uk/BusinessForm#completion> ?c .
          ?sg <http://www.assero.co.uk/BusinessForm#note> ?n .
          ?sg <http://www.assero.co.uk/BusinessForm#repeating> ?r .
          ?sg <http://www.assero.co.uk/BusinessForm#optional> ?o .
          ?sg <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
          BIND(?sg as ?g)
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      query_results.by_object_set([:g, :t, :l, :c, :n, :r, :o, :ordinal])
    end

    def query_bc(group)
      results = []
      query_string = %Q{
        SELECT ?g ?t ?l ?enabled ?optional ?local_label ?ordinal ?bc WHERE
        {
          #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasBiomedicalConcept> ?has_bc  .
          ?has_bc <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
          ?has_bc <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?has_bc <http://www.assero.co.uk/BusinessOperational#enabled> ?enabled .
          ?has_bc <http://www.assero.co.uk/BusinessOperational#optional> ?optional .
          ?has_bc <http://www.assero.co.uk/BusinessOperational#local_label> ?local_label .
          ?has_bc <http://www.assero.co.uk/BusinessOperational#ordinal> ?ordinal .
          ?has_bc <http://www.assero.co.uk/BusinessOperational#hasBiomedicalConcept> ?bc
          BIND(?has_bc as ?g)
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      triples = query_results.by_object_set([:g, :t, :l, :enabled, :optional, :local_label, :ordinal, :bc])
      triples.each do |x|
        results << OperationalReferenceV3.new(reference: x[:bc], ordinal: x[:ordinal], label: x[:l], optional: x[:optional], enabled: x[:enabled])
      end
      results
    end

    def query_common(group)
      query_string = %Q{
        SELECT ?g ?t ?l ?c ?n ?o ?ordinal WHERE
        {
          #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasCommon> ?cg  .
          ?cg <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
          ?cg <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?cg <http://www.assero.co.uk/BusinessForm#completion> ?c .
          ?cg <http://www.assero.co.uk/BusinessForm#note> ?n .
          ?cg <http://www.assero.co.uk/BusinessForm#optional> ?o .
          ?cg <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
          BIND(?cg as ?g)
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      query_results.by_object_set([:g, :t, :l, :c, :n, :o, :ordinal])
    end

    def query_items(group)
      query_string = %Q{
        SELECT ?i ?l ?c ?n ?o ?ordinal ?format ?mapping ?question_text ?free_text ?is_common ?datatype ?common_item ?type WHERE
        {
          #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasItem> ?i .
          ?i <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?i <http://www.assero.co.uk/BusinessForm#completion> ?c .
          ?i <http://www.assero.co.uk/BusinessForm#note> ?n .
          ?i <http://www.assero.co.uk/BusinessForm#optional> ?o .
          ?i <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
          OPTIONAL 
          {
            ?i <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.assero.co.uk/BusinessForm#Question> .
            ?i <http://www.assero.co.uk/BusinessForm#format> ?format .
            ?i <http://www.assero.co.uk/BusinessForm#mapping> ?mapping .
            ?i <http://www.assero.co.uk/BusinessForm#question_text> ?question_text .
            ?i <http://www.assero.co.uk/BusinessForm#datatype> ?datatype
            BIND ("Question" as ?type)
          }
          OPTIONAL 
          {
            ?i <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.assero.co.uk/BusinessForm#Mapping> .
            ?i <http://www.assero.co.uk/BusinessForm#mapping> ?mapping .
            BIND ("Mapping" as ?type)
          }
          OPTIONAL 
          {
            ?i <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.assero.co.uk/BusinessForm#Placeholder> .
            ?i <http://www.assero.co.uk/BusinessForm#free_text> ?free_text .
            BIND ("Placeholder" as ?type)
          }
          OPTIONAL 
          {
            ?i <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.assero.co.uk/BusinessForm#BcProperty> .
            ?i <http://www.assero.co.uk/BusinessForm#is_common> ?is_common .
            BIND ("BcProperty" as ?type)
          }
          OPTIONAL 
          {
            ?i <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.assero.co.uk/BusinessForm#CommonItem> .
            ?i <http://www.assero.co.uk/BusinessForm#hasCommonItem> ?common_item .
            BIND ("CommonItem" as ?type)
          }
          OPTIONAL 
          {
            ?i <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.assero.co.uk/BusinessForm#TextLabel> .
            BIND ("TextLabel" as ?type)
          }  
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:i, :l, :c, :n, :o, :ordinal, :format, :mapping, :question_text, :free_text, :is_common, :datatype, :common_item, :type ])
    end

    def query_tc(item)
      results = []
      query_string = %Q{
        SELECT ?coded_value WHERE
        {
          #{item[:i].to_ref} <http://www.assero.co.uk/BusinessForm#hasThesaurusConcept> ?tc .
          ?tc <http://www.assero.co.uk/BusinessOperational#hasThesaurusConcept> ?coded_value .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      triples = query_results.by_object_set([:coded_value])
      triples.each_with_index { |x, i| results << OperationalReferenceV3::TucReference.new(context: context(x[:coded_value]), reference: x[:coded_value], ordinal: i+1) }
      results
    end

    def context(cli_uri)
      cli = Thesaurus::UnmanagedConcept.find(cli_uri)
      cl = Thesaurus::ManagedConcept.find(cli.parents.last)
      context = @ct.find_by_identifiers([cl.identifier.dup, cli.identifier.dup])
      return context[cl.identifier]
    end

    def query_property(item)
      results = []
      query_string = %Q{
        SELECT ?property WHERE
        {
          #{item[:i].to_ref} <http://www.assero.co.uk/BusinessForm#hasProperty> ?has_property .
          ?has_property <http://www.assero.co.uk/BusinessOperational#hasProperty> ?property .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      triples = query_results.by_object_set([:property])
      triples.each_with_index { |x, i| results << OperationalReferenceV3.new(reference: x[:property], ordinal: i+1) }
      results
    end

    def add_form(params)
      {
        label: params[:l].blank? ? "Not Set" : params[:l],
        identifier: params[:i],
        has_group: []
      }
    end

    def add_group(form, params)
      form[:has_group] << {
          label: params[:l].blank? ? "Not Set" : params[:l],
          ordinal: params[:ordinal],
          note: params[:n].blank? ? "Not Set" : params[:n],
          completion: params[:c].blank? ? "Not Set" : params[:c],
          optional: params[:o].blank? ? "Not Set" : params[:o],
          repeating: params[:r].blank? ? "Not Set" : params[:r],
          has_item: [],
          has_sub_group: [],
          has_biomedical_concept: query_bc(params),
          has_common: []
      }
    end

    def add_sub_group(group, params)
      group[:has_sub_group] << {
        label: params[:l].blank? ? "Not Set" : params[:l],
        ordinal: params[:ordinal],
        note: params[:n].blank? ? "Not Set" : params[:n],
        completion: params[:c].blank? ? "Not Set" : params[:c],
        optional: params[:o].blank? ? "Not Set" : params[:o],
        repeating: params[:r].blank? ? "Not Set" : params[:r],
        has_item: [],
        has_sub_group: [],
        has_biomedical_concept: query_bc(params),
        has_common: []
      }
    end

    def add_common(group, params)
      group[:has_common] << {
        label: params[:l].blank? ? "Not Set" : params[:l],
        completion: params[:c].blank? ? "Not Set" : params[:c],
        optional: params[:o].blank? ? "Not Set" : params[:o],
        repeating: params[:r].blank? ? "Not Set" : params[:r],
        ordinal: params[:ordinal],
        note: params[:n].blank? ? "Not Set" : params[:n],
        has_item: []
      }
    end

    def add_item(group, params)
      case params[:type].to_sym
        when :Question
         item = {
          label: params[:l].blank? ? "Not Set" : params[:l],
          completion: params[:c].blank? ? "Not Set" : params[:c],
          note: params[:n],
          optional: params[:o],
          ordinal: params[:ordinal],
          mapping: params[:mapping],
          question_text: params[:question_text],
          format: params[:format],
          datatype: params[:datatype],
          has_coded_value: query_tc(params)
          }
          group[:has_item] << Form::Item::Question.from_h(item)
        when :Mapping
         item = {
            label: params[:l].blank? ? "Not Set" : params[:l],
            completion: params[:c].blank? ? "Not Set" : params[:c],
            note: params[:n],
            optional: params[:o],
            ordinal: params[:ordinal],
            mapping: params[:mapping]
          }
          group[:has_item] << Form::Item::Mapping.from_h(item)
        when :Placeholder
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              free_text: params[:free_text]
            }
          group[:has_item] << Form::Item::Placeholder.from_h(item)
        when :BcProperty
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              is_common: params[:is_common],
              has_coded_value: query_tc(params),
              has_property: query_property(params)
              }
          group[:has_item] << Form::Item::BcProperty.from_h(item)
        when :CommonItem
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              has_common_item: params[:common_item]
            }
          group[:has_item] << Form::Item::Common.from_h(item)
      end
    end

    def load_old_files
      files = ["FN000150_old.ttl", "FN000120_old.ttl", "VSTADIABETES_old.ttl"]
      #files = ["form_crf_test_1_old.ttl"]
      files.each {|f| load_local_file_into_triple_store(sub_dir, f)}
    end

    it "convert old" do
      results = []
      load_old_files
      forms = query_form
      forms.each do |f|
        groups = query_group(f)
        form = add_form(f)
        groups.each_with_index do |group, index|
          items = query_items(group)
          groups = add_group(form, group)
          items.each do |i|
            item = add_item(groups[index], i)
          end
          if !query_sub_group(group).empty?
            sub_groups = query_sub_group(group)
            sub_groups.each_with_index do |sub_group, inde|
              sub_items = query_items(sub_group)
              sub_groups = add_sub_group(groups[index], sub_group)
              sub_items.each do |si|
                item = add_item(sub_groups[inde], si)
              end
            end
          end
          if !query_common(group).empty?
            commons = query_common(group)
            commons.each_with_index do |common, ind|
              s_items = query_items(common)
              commons = add_common(groups[index], common)
              s_items.each do |si|
                item = add_item(commons[ind], si)
              end
            end
          end
        end
        results << form
      end
      results.each do |form_hash|
        sparql = Sparql::Update.new
        form = Form.from_h(form_hash)
        form.set_initial(form_hash[:identifier])
        sparql.default_namespace(form.uri.namespace)
        form.to_sparql(sparql, true)
        full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "#{form_hash[:identifier]}.ttl")
      end
    end

  end

end