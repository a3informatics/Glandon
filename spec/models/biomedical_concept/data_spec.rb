require 'rails_helper'

describe BiomedicalConcept do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/biomedical_concept/data"
  end

  def create_item(params, ordinal, bc_template=nil)
    t_item = find_item(bc_template, params[:label]) unless bc_template.nil?
    params = params_from_template(t_item) unless params[:enabled]
    params[:ordinal] = ordinal
    params[:mandatory] = t_item.nil? ? true : t_item.mandatory
    params[:collect] = params.key?(:collect) ? params[:collect] : true
    item = BiomedicalConcept::Item.new(label: params[:label], mandatory: params[:mandatory], collect: params[:collect], enabled: params[:enabled], ordinal: params[:ordinal])
    params[:has_complex_datatype].each do |datatype|
      datatype[:short_name] = datatype[:label] unless datatype.key?(:short_name) # Fix short_name if using template
      cdt = find_complex_datatype(datatype[:short_name])
      cdt = create_complex_datatype(datatype, cdt, t_item) 
      item.has_complex_datatype_push(cdt)
    end
    #puts "I Alias=#{item.to_h[:has_complex_datatype].map{|x| x[:has_property].map{|y| y[:alias]}}}"
    item
  end

  def params_from_template(t_item)
    return {} if t_item.nil?
    result = t_item.to_h
    result[:enabled] = false
    result
  end

  def find_item(bc_template, label)
    bc_template.has_item.find{|x| x.label == label}
  end

  def create_complex_datatype(params, cdt_template, t_item)
    t_cdt = nil
    template = t_item.nil? ? true : false
    cdt = BiomedicalConcept::ComplexDatatype.new(label: cdt_template.short_name)
    cdt.is_complex_datatype = cdt_template
    unless t_item.nil?
      t_item.has_complex_datatype_objects
      t_cdt = t_item.has_complex_datatype.find{|x| x.label == cdt_template.short_name}
    else
      t_cdt = cdt_template
    end
    params[:has_property].each do |property|
      cdt.has_property_push(create_property(property, t_cdt, template))
    end
    puts "CDT Alias=#{cdt.to_h[:has_property].map{|x| x[:alias]}}"
    cdt
  end

  def find_complex_datatype(short_name)
    return @cdt_set[short_name] if @cdt_set.key?(short_name)
    cdt = ComplexDatatype.where(short_name: short_name)
    cdt = ComplexDatatype.find_children(cdt.first.uri)
    @cdt_set[short_name] = cdt
    cdt
  end

  def create_property(params, t_cdt, template)
    params = params.merge(format: "", question_test: "", prompt_text: "") if t_cdt.nil?
    #puts "CP Params=#{params}"
    params = params.merge(alias: "xxx") unless template
    refs = params[:has_coded_value].blank? ? [] : params[:has_coded_value].dup
    params[:has_coded_value] = []
    property = BiomedicalConcept::PropertyX.new(label: params[:label], question_text: params[:question_text], prompt_text: params[:prompt_text], format: params[:format], alias: params[:alias])
    if template
      ref = CanonicalReference.where(label: params[:is_a])
      property.is_a = ref.first.uri unless ref.empty?
      puts colourize("***** Error finding Canonical ref: #{params[:alias]} #{params[:is_a]} *****", "red") if ref.empty?
      cdt_property = t_cdt.has_property.find{|x| x.label == params[:label]} 
      property.is_complex_datatype_property = cdt_property
      puts colourize("***** Error finding CDT property: #{params[:alias]} #{params[:label]} *****", "red") if cdt_property.nil?
    else
      t_cdt.has_property_objects
      t_property = t_cdt.has_property.find{|x| x.label == params[:label]} 
      property.alias = t_property.alias
      #puts "Template=#{t_property.to_h}"
      property.is_a = t_property.is_a
      cdt_properties = ComplexDatatype.find_children(t_cdt.is_complex_datatype)
      cdt_property = cdt_properties.has_property.find{|x| x.label == params[:label]} 
      property.is_complex_datatype_property = cdt_property
      refs.each_with_index do |term, index|
        if term[:cl].start_with?("C")
          items = @ct.find_by_identifiers([term[:cl].dup, term[:cli].dup])
        elsif term[:cl].start_with?("H")
          items = @ht.find_by_identifiers([term[:cl].dup, term[:cli].dup])
        end
        cl_uri = items[term[:cl]]
        cli_uri = items[term[:cli]]
        op_ref = OperationalReferenceV3::TucReference.new(context: cl_uri, reference: cli_uri, optional: true, ordinal: index+1)
        property.has_coded_value_push(op_ref) 
      end
    end
    #puts "CP Alias=#{property.to_h[:alias]}"
    property
  end

  def generate_instances(the_sub_dir, filename, write_file=false)
    results = []
    instances = read_yaml_file(the_sub_dir, filename)
    instances.each do |instance|
      template = BiomedicalConceptTemplate.find_full(Uri.new(uri: instance[:based_on]))
      object = BiomedicalConceptInstance.new(label: instance[:label])
      object.based_on = template.uri
      id_item = create_item(instance[:identified_by], 1, template)
      object.has_item_push(id_item)
      object.identified_by = id_item
      instance[:has_items].each_with_index do |item, index| 
        object.has_item_push(create_item(item, index+2, template))
      end
      #puts "Obj Final Alias=#{object.to_h[:has_item].map{|z| z[:has_complex_datatype].map{|x| x[:has_property].map{|y| y[:alias]}}}}"
      object.set_initial(instance[:identifier])
      results << object
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
    if write_file
      file_write_warning
      copy_file_from_public_files_rename("test", File.basename(full_path), the_sub_dir, "#{File.basename(filename, '.yaml')}.ttl")
    end
  end

  describe "production" do

    before :all do
      load_files(schema_files, ["hackathon_thesaurus.ttl"])
      load_cdisc_term_versions(1..68)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("canonical_references.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      @cdt_set = {}
      @ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V68#TH"))
      @ht = Thesaurus.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CT/V1#TH"))
    end

    it "create templates" do
      write_file = false
      results = []
      templates = read_yaml_file(sub_dir, "templates/templates.yaml")
      templates.each do |template|
        object = BiomedicalConceptTemplate.new(label: template[:label])
        id_item = create_item(template[:identified_by], 1)
        object.has_item_push(id_item)
        object.identified_by = id_item
        template[:has_items].each_with_index do |x, index| 
          object.has_item_push(create_item(x, index+2))
        end
        object.set_initial(template[:identifier])
        results << object
      end
      sparql = Sparql::Update.new
      sparql.default_namespace(results.first.uri.namespace)
      results.each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
      if write_file
        file_write_warning
        copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "templates/biomedical_concept_templates.ttl")
      end
    end

    it "create instances, by domain, production" do
      write_file = true
      load_local_file_into_triple_store("#{sub_dir}/templates", "biomedical_concept_templates.ttl")
      ["ae", "dm", "eg", "lb", "vs"].each do |dir|
        filenames = local_file_list("#{sub_dir}/instances/#{dir}", "*.yaml")
        filenames.each do |f|
          generate_instances("#{sub_dir}/instances/#{dir}", f, write_file)
        end
      end
    end

    it "check data" do
      load_local_file_into_triple_store("#{sub_dir}/templates", "biomedical_concept_templates.ttl")
      ["ae", "dm", "eg", "lb", "vs"].each do |dir|
        filenames = local_file_list("#{sub_dir}/instances/#{dir}", "*.ttl")
        filenames.each do |f|
          load_local_file_into_triple_store("#{sub_dir}/instances/#{dir}", f)
        end
      end
      expect(BiomedicalConceptTemplate.unique.count).to eq(6)
      expect(BiomedicalConceptInstance.unique.count).to eq(54)
    end

  end

  describe "local test" do

    before :all do
      load_files(schema_files, ["hackathon_thesaurus.ttl"])
      load_cdisc_term_versions(1..20)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("canonical_references.ttl")
      load_data_file_into_triple_store("complex_datatypes.ttl")
      @cdt_set = {}
      @ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V20#TH"))
      @ht = Thesaurus.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CT/V1#TH"))
    end

    it "create instances, local test" do
      write_file = true
      load_local_file_into_triple_store("#{sub_dir}/templates", "biomedical_concept_templates.ttl")
      generate_instances("#{sub_dir}/instances/test", "instances.yaml", write_file)
    end

  end

end