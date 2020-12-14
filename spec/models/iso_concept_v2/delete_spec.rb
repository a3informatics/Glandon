require 'rails_helper'

describe IsoConceptV2::IcCustomProperties do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include TripleStoreHelpers

	def sub_dir
    return "models/iso_concept_v2/ic_custom_properties"
  end

  def create_definition_1
    @definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Some String", 
      description: "A description XXX", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
  end

  def create_value(value, applies_to, context)
    contexts = context.is_a?(Array) ? context : [context.uri]
    object = CustomPropertyValue.new(value: "#{value}", custom_property_defined_by: @definition_1.uri, applies_to: applies_to.uri, context: contexts)
    object.uri = object.create_uri(object.class.base_uri)
    object.save
    object
  end

  def create_tag(applies_to)
    object = Classification.new(applies_to: applies_to, classified_as: @definition_1.uri, context: [applies_to])
    object.uri = object.create_uri(object.class.base_uri)
    object.save
    object
  end

  describe "clone custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "delete references" do
      create_definition_1
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      context_1 = Uri.new(uri: "http://www.example.com/A#context1")
      context_2 = Uri.new(uri: "http://www.example.com/A#context2")
      cp_1 = create_value("Object 1 String", object, [context_1, context_2])
      cp_2 = create_value(true, object, [context_1])
      cp_3 = create_value(false, object, [context_2])
      tag_1 = create_tag(object)
      results = object.delete_references
      expect{CustomPropertyValue.find(cp_1.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CPV#1760cbb1-a370-41f6-a3b3-493c1d9c2238 in CustomPropertyValue.")
      expect{CustomPropertyValue.find(cp_2.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CPV#4646b47a-4ae4-4f21-b5e2-565815c8cded in CustomPropertyValue.")
      expect{CustomPropertyValue.find(cp_3.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CPV#92bf8b74-ec78-4348-9a1b-154a6ccb9b9f in CustomPropertyValue.")
      expect{Classification.find(tag_1.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CLA#b76597f7-972f-40f4-bed7-e134725cf296 in Classification.")
      result = IsoConceptV2.find(object.uri)
    end

    it "delete or unlink" do
      create_definition_1
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      context_1 = Uri.new(uri: "http://www.example.com/A#context1")
      context_2 = Uri.new(uri: "http://www.example.com/A#context2")

      cp_1 = create_value("Object 1 String", object, [context_1, context_2])
      cp_2 = create_value(true, object, [context_1])
      cp_3 = create_value(false, object, [context_2])
      tag_1 = create_tag(object)

triple_store.subject_triples(cp_1.uri, true)
triple_store.subject_triples(cp_2.uri, true)
triple_store.subject_triples(cp_3.uri, true)
triple_store.subject_triples(tag_1.uri, true)
puts "----- START -----"
      
      results = object.delete_or_unlink_references(context_1)
      result = CustomPropertyValue.find(cp_1.uri)
      expect(result.context.count).to eq(1)
      expect(result.context.first).to eq(context_2)
      expect{CustomPropertyValue.find(cp_2.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CPV#4646b47a-4ae4-4f21-b5e2-565815c8cded in CustomPropertyValue.")
      result = CustomPropertyValue.find(cp_3.uri)
      expect(result.context.count).to eq(1)
      expect(result.context.first).to eq(context_2)
      expect{Classification.find(tag_1.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CLA#b76597f7-972f-40f4-bed7-e134725cf296 in Classification.")
      result = IsoConceptV2.find(object.uri)

triple_store.subject_triples(cp_1.uri, true)
triple_store.subject_triples(cp_2.uri, true)
triple_store.subject_triples(cp_3.uri, true)
triple_store.subject_triples(tag_1.uri, true)

    end

  end

end
