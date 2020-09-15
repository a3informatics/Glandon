class Form::Group < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Group",
            uri_suffix: "G",  
            uri_unique: true

  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  object_property :has_item, cardinality: :many, model_class: Form::Item, children: true

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }

private
  
  def text_row(text)
    return "<tr><td colspan=\"3\"><h5>#{text}</h5></td></tr>"
  end

  # Next Ordinal. Get the next ordinal for a managed item collection
  #
  # @param [String] name the name of the property holding the collection
  # @return [Integer] the next ordinal
  def next_ordinal(name)
    predicate = self.properties.property(name).predicate
    query_string = %Q{
      SELECT (MAX(?ordinal) AS ?max)
      {
        #{self.uri.to_ref} #{predicate.to_ref} ?s .
        ?s bf:ordinal ?ordinal
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bf])
    return 1 if query_results.empty?
    query_results.by_object(:max).first.to_i + 1
  end

end