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



  describe "Convert old forms" do

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
        SELECT ?g ?t ?l ?c ?n ?r ?o ?ordinal ?has_bc WHERE
        {
          #{group[:g].to_ref} <http://www.assero.co.uk/BusinessForm#hasSubGroup> ?sg  .
          ?sg <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
          ?sg <http://www.w3.org/2000/01/rdf-schema#label> ?l .
          ?sg <http://www.assero.co.uk/BusinessForm#completion> ?c .
          ?sg <http://www.assero.co.uk/BusinessForm#note> ?n .
          ?sg <http://www.assero.co.uk/BusinessForm#repeating> ?r .
          ?sg <http://www.assero.co.uk/BusinessForm#optional> ?o .
          ?sg <http://www.assero.co.uk/BusinessForm#ordinal> ?ordinal .
          OPTIONAL 
          {
            ?sg <http://www.assero.co.uk/BusinessForm#hasBiomedicalConcept> ?has_bc .
          }
          BIND(?sg as ?g)
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      return [] if query_results.empty?
      query_results.by_object_set([:g, :t, :l, :c, :n, :r, :o, :ordinal, :has_bc])
    end

    def query_bc(group)
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
      query_results.by_object_set([:g, :t, :l, :enabled, :optional, :local_label, :ordinal, :bc])
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
        SELECT ?i ?l ?c ?n ?o ?ordinal ?format ?mapping ?question_text ?free_text ?label_text ?datatype ?common_item ?type WHERE
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
            ?i <http://www.assero.co.uk/BusinessForm#label_text> ?label_text .
            BIND ("TextLabel" as ?type)
          }  
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      query_results.by_object_set([:i, :l, :c, :n, :o, :ordinal, :format, :mapping, :question_text, :free_text, :label_text, :datatype, :common_item, :type ])
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
          has_common: []
      }
    end

    def add_sub_group(group, params)
      if params[:has_bc].blank? #Normal subgroup
        hash_group = {
          label: params[:l].blank? ? "Not Set" : params[:l],
          ordinal: params[:ordinal],
          note: params[:n].blank? ? "Not Set" : params[:n],
          completion: params[:c].blank? ? "Not Set" : params[:c],
          optional: params[:o].blank? ? "Not Set" : params[:o],
          repeating: params[:r].blank? ? "Not Set" : params[:r],
          has_item: [],
          has_sub_group: [],
          has_common: []
        }
        group[:has_sub_group] << Form::Group::Normal.from_h(hash_group)
      else #BC subgroup
        hash_group = {
        label: params[:l].blank? ? "Not Set" : params[:l],
        ordinal: params[:ordinal],
        note: params[:n].blank? ? "Not Set" : params[:n],
        completion: params[:c].blank? ? "Not Set" : params[:c],
        optional: params[:o].blank? ? "Not Set" : params[:o],
        has_item: [],
        has_biomedical_concept: []
      }
        group[:has_sub_group] << Form::Group::Bc.from_h(hash_group)
      end
    end

    def add_bc(group, params)
      bc = {
          reference: params[:bc],
          optional: params[:optional],
          ordinal: params[:ordinal],
          label: params[:l],
          enabled: params[:enabled]
          }
       group.has_biomedical_concept = OperationalReferenceV3.from_h(bc)
    end

    def add_common(group, params)
      common = {
          label: params[:l].blank? ? "Not Set" : params[:l],
          completion: params[:c].blank? ? "Not Set" : params[:c],
          optional: params[:o].blank? ? "Not Set" : params[:o],
          ordinal: params[:ordinal],
          note: params[:n].blank? ? "Not Set" : params[:n],
          has_item: []
          }
       group[:has_common] << Form::Group::Common.from_h(common)
    end

    def add_item_group(group, params)
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
        when :TextLabel
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              label_text: params[:label_text]
            }
          group[:has_item] << Form::Item::TextLabel.from_h(item)
      end
    end

    def add_item_sub_group(group, params)
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
          group.has_item << Form::Item::Question.from_h(item)
        when :Mapping
         item = {
            label: params[:l].blank? ? "Not Set" : params[:l],
            completion: params[:c].blank? ? "Not Set" : params[:c],
            note: params[:n],
            optional: params[:o],
            ordinal: params[:ordinal],
            mapping: params[:mapping]
          }
          group.has_item << Form::Item::Mapping.from_h(item)
        when :Placeholder
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              free_text: params[:free_text]
            }
          group.has_item << Form::Item::Placeholder.from_h(item)
        when :BcProperty
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              has_coded_value: query_tc(params),
              has_property: query_property(params)
              }
          group.has_item << Form::Item::BcProperty.from_h(item)
        when :CommonItem
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              has_common_item: params[:common_item]
            }
          group.has_item << Form::Item::Common.from_h(item)
        when :TextLabel
          item =  {
              label: params[:l].blank? ? "Not Set" : params[:l],
              completion: params[:c].blank? ? "Not Set" : params[:c],
              note: params[:n],
              optional: params[:o],
              ordinal: params[:ordinal],
              label_text: params[:label_text]
            }
          group.has_item << Form::Item::TextLabel.from_h(item)
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
            item = add_item_group(groups[index], i)
          end
          if !query_sub_group(group).empty?
            sub_groups = query_sub_group(group)
            sub_groups.each_with_index do |sub_group, inde|
              sub_items = query_items(sub_group)
              sub_groups = add_sub_group(groups[index], sub_group)
              sub_items.each do |si|
                item = add_item_sub_group(sub_groups[inde], si)
              end
              if !query_bc(sub_group).empty?
                sub_bcs = query_bc(sub_group)
                sub_bcs.each do |bc|
                  bc = add_bc(sub_groups[inde], bc)
                end
              end
              if !query_common(group).empty?
                commons = query_common(group)
                commons.each_with_index do |cm, ind|
                  sub_commons = query_items(cm)
                  commons = add_common(groups[index], cm)
                  sub_commons.each do |sc|
                    item = add_item_sub_group(commons[ind], sc)
                  end
                end
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

  describe "Create hackathon form" do
    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V2.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V3.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V4.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V5.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V6.ttl")
      load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V7.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")      
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")      
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("association_IG_domain.ttl")      
    end

    after :all do
      delete_all_public_test_files
    end

    it "create simple form" do
      form = Form.create(label: "Form", identifier: "AAA")
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      bci_1 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.first.uri)
      question.mapping = "VSORRESU"
      question.datatype = "datetype" 
      question.question_text = "Question text 1"
      question.save
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.second.uri)
      question.mapping = "VSORRES"
      question.datatype = "datetype" 
      question.question_text = "Question text 2"
      question.save
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id]})
      simple_form = Form.find_full(form.uri)
      full_path = simple_form.to_ttl
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "hackathon_form.ttl")
    end
  end

  describe "Create forms" do

    def form_to_ttl(form)
      uri = form.has_identifier.has_scope.uri
      form.has_identifier.has_scope = uri
      uri = form.has_state.by_authority.uri
      form.has_state.by_authority = uri
      form.to_ttl
    end

    before :all do
      data_files = ["biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")   
    end

    after :all do
      delete_all_public_test_files
    end

    it "Bc only group" do
      form = Form.create(label: "Form", identifier: "F001")
      form.add_child({type:"normal_group"})
      bci_1 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_4 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      form = Form.find_full(form.uri)
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id, bci_4.id]})
      simple_form = Form.find_full(form.uri)
      full_path = form_to_ttl(simple_form)
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "F001_bc_only_group_form.ttl")
    end

    it "Question only group" do
      form = Form.create(label: "Form", identifier: "F002")
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.first.uri)
      question.mapping = "VSORRESU"
      question.datatype = "datetype" 
      question.question_text = "Question text 1"
      question.save
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.second.uri)
      question.mapping = "VSORRES"
      question.datatype = "datetype" 
      question.question_text = "Question text 2"
      question.save
      simple_form = Form.find_full(form.uri)
      full_path = form_to_ttl(simple_form)
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "F002_question_only_group_form.ttl")
    end

    it "simple form" do
      form = Form.create(label: "Form", identifier: "F003")
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.first.uri)
      question.mapping = "VSORRESU"
      question.datatype = "datetype" 
      question.question_text = "Question text 1"
      question.save
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.second.uri)
      question.mapping = "VSORRES"
      question.datatype = "datetype" 
      question.question_text = "Question text 2"
      question.save
      normal_group.add_child({type:"placeholder"})
      normal_group.add_child({type:"text_label"})
      simple_form = Form.find_full(form.uri)
      full_path = form_to_ttl(simple_form)
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "F003_simple_form.ttl")
    end

    it "complex form" do
      form = Form.create(label: "Form", identifier: "F004")
      form.add_child({type:"normal_group"})
      form.add_child({type:"normal_group"})
      form.add_child({type:"normal_group"})
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      normal_group_1 = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group_2 = Form::Group::Normal.find_full(form.has_group.second.uri)
      normal_group_3 = Form::Group::Normal.find_full(form.has_group.third.uri)
      normal_group_4 = Form::Group::Normal.find_full(form.has_group.fourth.uri)
  
      normal_group_1.add_child({type:"question"})
      normal_group_1 = Form::Group::Normal.find_full(form.has_group.first.uri)
      question_1 = Form::Item::Question.find_full(normal_group_1.has_item.first.uri)
      question_1.mapping = "VSORRESU"
      question_1.datatype = "datetype" 
      question_1.question_text = "Question text 1"
      question_1.label = "Question 1"
      question_1.save
      normal_group_1.add_child({type:"question"})
      normal_group_1 = Form::Group::Normal.find_full(form.has_group.first.uri)
      question_2 = Form::Item::Question.find_full(normal_group_1.has_item.second.uri)
      question_2.mapping = "VSORRES"
      question_2.datatype = "datetype" 
      question_2.question_text = "Question text 2"
      question_2.label = "Question 2"
      question_2.save

      normal_group_2.add_child({type:"question"})
      normal_group_2 = Form::Group::Normal.find_full(form.has_group.second.uri)
      question_3 = Form::Item::Question.find_full(normal_group_2.has_item.first.uri)
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49507"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C25376"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      question_3.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}, {id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}]})
      question_3.mapping = "VSORRESU"
      question_3.datatype = "string" 
      question_3.question_text = "Question text 1"
      question_3.label = "Question 1"
      question_3.save
      normal_group_2.add_child({type:"placeholder"})
      normal_group_2.add_child({type:"text_label"})

      bci_1 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      normal_group_3.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id]})

      normal_group_4.add_child({type:"common_group"})
      normal_group_4.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id]})
      normal_group_4 = Form::Group::Normal.find_full(form.has_group.fourth.uri)
      cg = Form::Group::Common.find_full(normal_group_4.has_common.first.uri)
      bcg = Form::Group::Bc.find_full(normal_group_4.has_sub_group.first.uri)
      bc_property = Form::Item::BcProperty.find_full(bcg.has_item.first.uri)
      bc_property.make_common(cg)

      simple_form = Form.find_full(form.uri)
      full_path = form_to_ttl(simple_form)
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "F004_complex_form.ttl")
    end

    it "Repeating Bc only group" do
      form = Form.create(label: "Form", identifier: "F005")
      form.add_child({type:"normal_group"})
      bci_1 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      form = Form.find_full(form.uri)
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.repeating = true
      normal_group.save
      normal_group.add_child({type:"bc_group", id_set:[bci_1.id, bci_2.id, bci_3.id]})
      simple_form = Form.find_full(form.uri)
      full_path = form_to_ttl(simple_form)
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "F005_repeating_bc_only_group_form.ttl")
    end

    it "Repeating Question only group" do
      form = Form.create(label: "Form", identifier: "F006")
      form.add_child({type:"normal_group"})
      form = Form.find_full(form.uri)
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      normal_group.repeating = true
      normal_group.save
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.first.uri)
      question.mapping = "VSORRESU"
      question.datatype = "datetype" 
      question.question_text = "Question text 1"
      question.save
      normal_group.add_child({type:"question"})
      normal_group = Form::Group::Normal.find_full(form.has_group.first.uri)
      question = Form::Item::Question.find_full(normal_group.has_item.second.uri)
      question.mapping = "VSORRES"
      question.datatype = "datetype" 
      question.question_text = "Question text 2"
      question.save
      simple_form = Form.find_full(form.uri)
      full_path = form_to_ttl(simple_form)
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "F006_repeating_question_only_group_form.ttl")
    end


  end

end