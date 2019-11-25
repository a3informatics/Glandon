module IsoConceptSystem::Core

  # Add a child object
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def add(params)
    klass = self.properties.property(children_property).klass
    transaction_begin
    params[:pref_label] = params.delete(:label) # rename lable to pref_label, legacy reasons.
    params[:uri] = create_uri(self.uri)
    child = klass.create(params)
    child.errors.add(:base, "This tag label already exists at this level.") if self.has_child?(params[:pref_label])
    return child if child.errors.any?
    self.add_link(children_property, child.uri)
    transaction_execute
    child
  end

  # Update
  #
  # @raise [UpdateError] If object not updated.
  # @return [Boolean] The new object created if no exception raised
  def update(params)
    params[:pref_label] = params.delete(:label) # rename label to pref_label, legacy reasons.
    #self.properties.assign(params) if !params.empty?
    #return if !valid?
    #partial_update(update_query(params), [:isoC])
    super
  end

  # Has child
  #
  # @param [String] label of the new tag
  # @return [Boolean] returns true if this instance already has a child with an identical pref_label
  def has_child?(label)
    query_string = "SELECT ?s WHERE {
      #{self.uri.to_ref} #{self.properties.property(children_property).predicate.to_ref} ?s .
        ?s #{self.properties.property(:pref_label).predicate.to_ref} ?t .
          FILTER (UCASE(?t) = UCASE('#{label}')) .
      }"
    results = Sparql::Query.new.query(query_string, "", [])
    !results.empty?
  end

private

  # Update query string
  # def update_query(params)
  #   %Q{
  #     DELETE
  #     {
  #     #{self.uri.to_ref} isoC:prefLabel ?a .
  #     #{self.uri.to_ref} isoC:description ?b .
  #     }
  #     INSERT
  #     {
  #     #{self.uri.to_ref} isoC:prefLabel "#{self.pref_label}"^^xsd:string .
  #     #{self.uri.to_ref} isoC:description "#{self.description}"^^xsd:string .
  #     }
  #     WHERE
  #     {
  #     #{self.uri.to_ref} isoC:prefLabel ?a .
  #     #{self.uri.to_ref} isoC:description ?b .
  #     }
  #   }
  # end

end
