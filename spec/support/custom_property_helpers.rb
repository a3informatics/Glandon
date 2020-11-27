module CustomPropertyHelpers

  class TestParent < IsoManagedV2

    configure rdf_type: "http://www.assero.co.uk/Test#ManagedConcept",
              base_uri: "http://www.assero.co.uk/MC",
              uri_unique: true

    object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true

  end

  class TestChild < IsoConceptV2

    configure rdf_type: "http://www.assero.co.uk/Test#UnmanagedConcept",
              base_uri: "http://www.assero.co.uk/UC",
              uri_unique: true

  end

  def create_definitions
    @definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Some String", 
      description: "A description XXX", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
    @definition_2 = CustomPropertyDefinition.create(datatype: "boolean", label: "A Flag", 
      description: "A description YYY", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD2"))
  end

  def create_custom(context, applies_to, value, definition, index)
    CustomPropertyValue.create(value: value, context: [context.uri], applies_to: applies_to.uri, 
      custom_property_defined_by: definition.uri, uri: Uri.new(uri: "http://www.assero.co.uk/CP##{index}"))
  end

  def create_data
    @parent = TestParent.create(identifier: "XXX", label: "Parent")
    @child_1 = TestChild.create(label: "Child 1")
    @child_2 = TestChild.create(label: "Child 2")
    @child_3 = TestChild.create(label: "Child 3")
    @parent.narrower = [@child_1, @child_2, @child_3]
    @parent.save
    create_custom(@parent, @child_1, "String 1", @definition_1, 1)
    create_custom(@parent, @child_1, "true", @definition_2, 2)
    create_custom(@parent, @child_2, "String 2", @definition_1, 3)
    create_custom(@parent, @child_2, "false", @definition_2, 4)
    create_custom(@parent, @child_3, "String 3", @definition_1, 5)
    create_custom(@parent, @child_3, "false", @definition_2, 6)
  end

end