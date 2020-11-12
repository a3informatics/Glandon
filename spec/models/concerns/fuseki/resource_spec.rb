require 'rails_helper'

describe Fuseki::Resource do
  
  include DataHelpers
  include PublicFileHelpers
  include FusekiBaseHelpers

  def sub_dir
    return "models/concerns/fuseki/resource"
  end

  def string_datatype_to_h
    {datatype: "http://www.w3.org/2001/XMLSchema#string", fragment: "string"}
  end

  describe "create resources" do

    before :each do
      clear_triple_store
    end

    after :each do
    end

    class TestR1 < Fuseki::Base
      extend Fuseki::Resource
      extend Fuseki::Schema

      def xxx
        return 14
      end

    end

    class TestR2 < Fuseki::Base
      extend Fuseki::Resource
      extend Fuseki::Schema
    end

    class TestR3 < Fuseki::Base
      extend Fuseki::Resource
      extend Fuseki::Schema
    end

    class TestR4 < Fuseki::Base
      extend Fuseki::Resource
      extend Fuseki::Schema
    end

    class TestR5 < Fuseki::Base
      extend Fuseki::Resource
      extend Fuseki::Schema
    end

    class TestR6 < Fuseki::Base
      extend Fuseki::Resource
      extend Fuseki::Schema
    end

    class TestR7 < TestR6
    end

    class TestRTarget
    end

    class TestRTargetUpdated1
    end

    class TestRTargetUpdated2
    end

    class TestRTargetUpdated3
    end

    it "error if RDF type not configured" do
      expect{TestR1.configure({})}.to raise_error(Errors::ApplicationLogicError, "No RDF type specified when configuring class.")
    end

    it "RDF type configured" do
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX"})
      expect(TestR1.respond_to?(:rdf_type)).to eq(true)
      item = TestR1.new
      expect(item.respond_to?(:rdf_type)).to eq(true)
      expect(TestR1.instance_variable_get(:@resources)).to eq({}) # Make sure we clear properties.
    end

    it "URI generation configured, unique" do
      parent = Uri.new(uri: "http://www.example.com/A#XXX")
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX", base_uri: "http://www.example.com/X", uri_unique: true})
      item = TestR1.new
      expect(item.respond_to?(:create_uri)).to eq(true)
      result = item.create_uri(parent)
      expect(result.to_s.length > parent.to_s.length).to eq(true)
      expect(result.to_s).to start_with("http://www.example.com/X")
    end

    it "URI generation configured, unique & suffix" do
      parent = Uri.new(uri: "http://www.example.com/A#XXX")
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_unique: true, uri_suffix: "YYY"})
      item = TestR1.new
      expect(item.respond_to?(:create_uri)).to eq(true)
      result = item.create_uri(parent)
      expect(result.to_s.length > parent.to_s.length).to eq(true)
      expect(result.to_s).to start_with("http://www.example.com/A#")
    end

    it "URI generation configured, suffix" do
      parent = Uri.new(uri: "http://www.example.com/A#XXX")
      expected = "#{parent.to_s}_AAA"
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_suffix: "AAA"})
      item = TestR1.new
      expect(item.respond_to?(:create_uri)).to eq(true)
      result = item.create_uri(parent)
      expect(result.to_s).to eq(expected)
      expect(result.equal?(parent)).to eq(false)
    end

    it "URI generation configured, property" do
      parent = Uri.new(uri: "http://www.example.com/A#XXX")
      expected = "#{parent.to_s}_14"
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_property: :xxx})
      item = TestR1.new
      expect(item.respond_to?(:create_uri)).to eq(true)
      result = item.create_uri(parent)
      expect(result.to_s).to eq(expected)
    end

    it "URI generation configured, property & prefix" do
      parent = Uri.new(uri: "http://www.example.com/A#XXX")
      expected = "#{parent.to_s}_BBB14"
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX", uri_suffix: "BBB", uri_property: :xxx})
      item = TestR1.new
      expect(item.respond_to?(:create_uri)).to eq(true)
      result = item.create_uri(parent)
      expect(result.to_s).to eq(expected)
    end

    it "error if cardinality not configured" do
      expect{TestR2.object_property({})}.to raise_error(Errors::ApplicationLogicError, "No cardinality specified for object property.")
    end

    it "error if class not configured" do
      expect{TestR3.object_property(:fred, {cardinality: :one})}.to raise_error(Errors::ApplicationLogicError, "No model class specified for object property.")
    end

    it "object property configured" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      fred_expected = {:base_type=>"", :cardinality=>:one, :default=>nil, :model_classes=>[TestRTarget], :read_exclude=>false, :delete_exclude=>false, :name=>:fred, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#fred")}
      sid_expected = {:base_type=>"", :cardinality=>:many, :default=>[], :model_classes=>[TestRTarget], :read_exclude=>true, :delete_exclude=>false, :name=>:sid, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#sid")}
      TestR4.object_property(:fred, {cardinality: :one, model_class: "TestRTarget"})
      expect(TestR4.instance_variable_get(:@resources)).to eq({:fred => fred_expected})
      TestR4.object_property(:sid, {cardinality: :many, model_class: "TestRTarget", read_exclude: true})
      expect(TestR4.instance_variable_get(:@resources)).to eq({:fred => fred_expected, :sid => sid_expected}) 
    end

    it "object property configured, exclude" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      fred_expected = {:base_type=>"", :cardinality=>:one, :default=>nil, :model_classes=>[TestRTarget], :read_exclude=>false, :delete_exclude=>false, :name=>:fred, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#fred")}
      sid_expected = {:base_type=>"", :cardinality=>:many, :default=>[], :model_classes=>[TestRTarget], :read_exclude=>true, :delete_exclude=>true,  :name=>:sid, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#sid")}
      TestR4.object_property(:fred, {cardinality: :one, model_class: "TestRTarget"})
      expect(TestR4.instance_variable_get(:@resources)).to eq({:fred => fred_expected})
      TestR4.object_property(:sid, {cardinality: :many, model_class: "TestRTarget", read_exclude: true, delete_exclude: true})
      expect(TestR4.instance_variable_get(:@resources)).to eq({:fred => fred_expected, :sid => sid_expected}) 
    end

    it "object property configured, exclude bad value" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      sid_expected = {:base_type=>"", :cardinality=>:many, :default=>[], :model_classes=>[TestRTarget], :read_exclude=>true, :delete_exclude=>true, :name=>:sid, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#sid")}
      TestR4.object_property(:sid, {cardinality: :many, model_class: "TestRTarget", read_exclude: true, delete_exclude: "x"})
      expect(TestR4.instance_variable_get(:@resources)).to hash_equal({:sid => sid_expected}) 
    end

    it "object property class configured" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      fred_expected = {:base_type=>"", :cardinality=>:one, :default=>nil, :model_classes=>[TestRTarget, TestRTargetUpdated1, TestRTargetUpdated2, TestRTargetUpdated3], :read_exclude=>false, :delete_exclude=>false, :name=>:fred, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#fred")}
      TestR4.object_property(:fred, {cardinality: :one, model_class: "TestRTarget"})
      TestR4.object_property_class(:fred, {model_class: "TestRTargetUpdated1"})
      TestR4.object_property_class(:fred, {model_classes: ["TestRTargetUpdated2", "TestRTargetUpdated3"]})
      expect(TestR4.instance_variable_get(:@resources)).to eq({:fred => fred_expected})
    end

    it "error if additional class not configured" do
      expect{TestR3.object_property_class(:fred, {})}.to raise_error(Errors::ApplicationLogicError, "No model class(es) specified for object property class.")
    end

    it "data property configured, no default" do
      metadata = Fuseki::Schema::SchemaMap.new({})
      expect(TestR5).to receive(:schema_metadata).and_return(metadata)
      expect(metadata).to receive(:datatype).and_return("string")
      TestR5.configure({rdf_type: "http://www.example.com/C#YYY"})
      fred1_expected = 
      {
        :base_type=>string_datatype_to_h, 
        :cardinality=>:one, :default=>"", :model_classes=>[], :read_exclude=>false, :delete_exclude=>false, :name=>:fred1, :type=>:data, 
        predicate: Uri.new(uri: "http://www.example.com/C#fred1")
      }
      TestR5.data_property(:fred1)
      expect(all_metadata(TestR5.instance_variable_get(:@resources))).to hash_equal({:fred1 => fred1_expected})    
    end

    it "data property configured, default" do
      metadata = Fuseki::Schema::SchemaMap.new({})
      expect(TestR6).to receive(:schema_metadata).and_return(metadata)
      expect(metadata).to receive(:datatype).and_return("string")
      TestR6.configure({rdf_type: "http://www.example.com/C#YYY"})
      fred2_expected = 
      {
        :base_type=>string_datatype_to_h, 
        :cardinality=>:one, :default=>"default value", :model_classes=>[], :read_exclude=>false, :delete_exclude=>false, :name=>:fred2, :type=>:data, 
        predicate: Uri.new(uri: "http://www.example.com/C#fred2")
      }
      TestR6.data_property(:fred2, {default: "default value"})
      expect(all_metadata(TestR6.instance_variable_get(:@resources))).to hash_equal({:fred2 => fred2_expected})    
    end

    it "key property" do
      parent = Uri.new(uri: "http://www.example.com/A#XXX")
      TestR1.configure({rdf_type: "http://www.example.com/A#XXX", key_property: :xxx})
      expect(TestR1.respond_to?(:key_property)).to eq(true)
      item = TestR1.new
      expect(item.respond_to?(:key_property)).to eq(false)
      expect(TestR1.key_property).to eq(:xxx)
    end

    it "children properties" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      fred_expected = {:base_type=>"", :cardinality=>:one, :children=>true, :default=>nil, :model_classes=>[TestRTarget], :read_exclude=>false, :delete_exclude=>false, :name=>:fred, :type=>:object, predicate: Uri.new(uri: "http://www.example.com/B#fred")}
      TestR4.object_property(:fred, {cardinality: :one, model_class: "TestRTarget", children: true})
      expect(TestR4.instance_variable_get(:@resources)).to hash_equal({:fred => fred_expected})
      item = TestR4.new
      expect(TestR4.respond_to?(:children_property_name)).to eq(true)
      expect(TestR4.children_property_name).to eq(:fred)
      expect(TestR4.respond_to?(:children_klass)).to eq(true)
      expect(TestR4.children_klass).to eq(TestRTarget)
      expect(TestR4.respond_to?(:children_predicate)).to eq(true)
      expect(TestR4.children_predicate.to_s).to eq("http://www.example.com/B#fred")
      expect(TestR4.children_predicate?).to eq(true)
      expect(item.respond_to?(:children)).to eq(true)
      expect(item.children).to eq(nil)
      expect(item.respond_to?(:children_objects)).to eq(true)
    end

    it "object and link properties" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      TestR4.object_property(:fred, {cardinality: :one, model_class: "TestRTarget"})
      expect(TestR4.children_predicate?).to eq(false)
      item = TestR4.new
      expect(item.respond_to?(:fred_links)).to eq(true)
      expect(item.respond_to?(:fred_links?)).to eq(true)
      expect(item.respond_to?(:fred_objects)).to eq(true)
      expect(item.respond_to?(:fred_objects?)).to eq(true)
    end

    it "object and push method" do
      TestR4.configure({rdf_type: "http://www.example.com/B#YYY"})
      TestR4.object_property(:fred, {cardinality: :many, model_class: "TestRTarget", children: true})
      item = TestR4.new
      expect(item.respond_to?(:fred_push)).to eq(true)
    end

  end

  describe "read metadata" do

    before :all do
    end

    after :all do
    end

    class TestR11 < FusekiBaseHelpers::TestRegistrationAuthorities

      configure rdf_type: "http://www.assero.co.uk/Fake1"

      object_property :ra_namespace, cardinality: :many, model_class: "TestRTarget"

    end 

    class TestR12 < TestR11

      configure rdf_type: "http://www.assero.co.uk/Fake2"

      object_property :ra_namespace, cardinality: :many, model_class: "TestRTarget"

    end 

    class TestR14 < TestR11

      configure rdf_type: "http://www.assero.co.uk/Fake3"

      object_property :ra_namespace, cardinality: :many, model_class: "TestR14"

    end 

    class TestR15 < TestR11

      configure rdf_type: "http://www.assero.co.uk/Fake4"

      object_property :ra_namespace, cardinality: :many, model_class: "TestR14"

    end 

    it "get properties, class and instance" do
      result = FusekiBaseHelpers::TestRegistrationAuthorities.resources
      check_file_actual_expected(all_metadata(result), sub_dir, "properties_metadata_expected_1.yaml", equate_method: :hash_equal)
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      result = item.class.resources
      check_file_actual_expected(all_metadata(result), sub_dir, "properties_metadata_expected_1.yaml", equate_method: :hash_equal)
    end

    it "object relationships" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.object_relationships, sub_dir, "relationships_expected_1.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.object_relationships, sub_dir, "relationships_expected_1.yaml")
    end

    it "property relationships" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.property_relationships, sub_dir, "relationships_expected_2.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.property_relationships, sub_dir, "relationships_expected_2.yaml")
    end

    it "read paths" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.read_paths, sub_dir, "managed_paths_expected_1.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.read_paths, sub_dir, "managed_paths_expected_1.yaml")
    end

    it "read paths" do
      check_file_actual_expected(TestR14.read_paths, sub_dir, "managed_paths_expected_4.yaml")
      item = TestR14.new
      check_file_actual_expected(item.class.read_paths, sub_dir, "managed_paths_expected_4.yaml")
    end

    it "read paths" do
      check_file_actual_expected(TestR15.read_paths, sub_dir, "managed_paths_expected_5.yaml")
      item = TestR15.new
      check_file_actual_expected(item.class.read_paths, sub_dir, "managed_paths_expected_5.yaml")
    end

    it "read paths, empty array, default" do
      check_file_actual_expected(TestR15.read_paths, sub_dir, "managed_paths_expected_5.yaml")
      item = TestR15.new
      check_file_actual_expected(item.class.read_paths, sub_dir, "managed_paths_expected_5.yaml")
    end

    it "read property paths" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.read_property_paths(property: :ra_namespace), sub_dir, "property_paths_expected_1.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.read_property_paths(property: :ra_namespace), sub_dir, "managed_paths_expected_1.yaml")
    end

    it "read property paths, empty array, default" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.read_property_paths(property: :ra_namespace), sub_dir, "property_paths_expected_1.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.read_property_paths(property: :ra_namespace), sub_dir, "managed_paths_expected_1.yaml")
    end

    it "delete paths" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.delete_paths, sub_dir, "managed_paths_expected_2.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.delete_paths, sub_dir, "managed_paths_expected_2.yaml")
    end

    it "delete paths, empty array, default" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.delete_paths, sub_dir, "managed_paths_expected_2.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.delete_paths, sub_dir, "managed_paths_expected_2.yaml")
    end

    it "delete property paths" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.delete_property_paths(property: :ra_namespace), sub_dir, "property_paths_expected_2.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.delete_property_paths(property: :ra_namespace), sub_dir, "property_paths_expected_2.yaml")
    end

    it "delete property paths, empty array, default" do
      check_file_actual_expected(FusekiBaseHelpers::TestRegistrationAuthorities.delete_property_paths(property: :ra_namespace), sub_dir, "property_paths_expected_2.yaml")
      item = FusekiBaseHelpers::TestRegistrationAuthorities.new
      check_file_actual_expected(item.class.delete_property_paths(property: :ra_namespace), sub_dir, "property_paths_expected_2.yaml")
    end

    it "updates property" do
      item = TestR11.new
      result = item.class.resources
      check_file_actual_expected(all_metadata(result), sub_dir, "properties_metadata_expected_3.yaml", equate_method: :hash_equal)
    end

    it "rdf type to klass" do
      expect(TestR11.rdf_type_to_klass("http://www.assero.co.uk/Fake1")).to eq(TestR11)
      expect(TestR12.rdf_type_to_klass("http://www.assero.co.uk/Fake2")).to eq(TestR12)
      expect(TestR11.rdf_type_to_klass("http://www.assero.co.uk/Fake3")).to eq(TestR14)
      expect(TestR12.rdf_type_to_klass("http://www.assero.co.uk/Fake4")).to eq(TestR15)
    end

  end

end