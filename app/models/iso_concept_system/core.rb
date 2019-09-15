module IsoConceptSystem::Core

  # Add a child object
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def add(params)
    transaction_begin
    params[:pref_label] = params.delete(:label) # rename lable to pref_label, legacy reasons.
    params[:uri] = create_uri(self.uri)
    child = self.class.create(params) 
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
    params[:pref_label] = params.delete(:label) # rename lable to pref_label, legacy reasons.
    self.properties.assign(params) if !params.empty?
    return if !valid?
    partial_update(update_query(params), [:isoC])
  end

private

  # Update query string
  def update_query(params)
    %Q{
      DELETE
      {
      #{self.uri.to_ref} isoC:prefLabel ?a .
      #{self.uri.to_ref} isoC:description ?b .
      }
      INSERT
      {
      #{self.uri.to_ref} isoC:prefLabel "#{self.pref_label}"^^xsd:string .
      #{self.uri.to_ref} isoC:description "#{self.description}"^^xsd:string .
      }
      WHERE
      {
      #{self.uri.to_ref} isoC:prefLabel ?a .
      #{self.uri.to_ref} isoC:description ?b .
      }
    }
  end

end