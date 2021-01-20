# ISO Managed Association. Methods to handle associations
#
# @author 
# @since 
class IsoManagedV2
  
  module Associations

    # Associate. 
    #
    # @param [Array] ids set the ids to add as associated
    # @param [String] semantic define the association type
    # @return [Association] new association or existing one with associated links
    def associate(ids, semantic)
      association = self.association? ? Association.find(self.association)  : new_association(the_subject: self.uri, semantic: semantic)
      association.associated_with += ids.map{|x| Uri.new(id: x)}
      association.save
      association
    end

    # Diassociate. 
    #
    # @param [Array] ids set the ids to add as associated
    # @return [Object] 
    def diassociate(ids)
      if self.association? 
        association = Association.find(self.association)
        ids.map{|x| Uri.new(id: x)}.each do |uri| 
          association.properties.property(:associated_with).delete_value(uri)
        end
        association.save
        association
      else
        self.errors.add(:base, "Failed to find association")
        self
      end
    end

    # Diassociate All. 
    #
    # @return [Void]
    def diassociate_all
      if self.association?
        association = Association.find(self.association)
        association.delete
        1
      else
        self.errors.add(:base, "Failed to find association")
        self
      end
    end

    # Association?
    #
    # @result [Boolean] return true if exists an association for the subject
    def association?
      Sparql::Query.new.query("ASK {#{self.uri.to_ref} (^bo:theSubject) ?o}", "", [:bo]).ask? 
    end

    # Association
    #
    # @result [Uri] return the uri of an association
    def association
      results = Sparql::Query.new.query("SELECT ?assoc WHERE {?assoc bo:theSubject #{self.uri.to_ref}}", "", [:bo])
      Errors.application_error(self.class.name, __method__.to_s, "No associations were found.") if results.empty?
      objects = []
      results.by_object(:assoc).each do |object|
        objects << object
      end
      Errors.application_error(self.class.name, __method__.to_s, "Multiple associations found.") if objects.count > 1
      objects.first
    end

    # Associated. List the objects associated with the subject.
    #
    # @param 
    # @return
    def associated
      results = []
      query_string = %Q{
        SELECT DISTINCT ?s ?i ?l ?sv ?vl ?owner ?rdf_type WHERE {
          #{self.uri.to_ref} ^bo:theSubject ?assoc .
          ?assoc bo:associatedWith ?s .
          ?s isoT:hasIdentifier/isoI:identifier ?i .
          ?s isoC:label ?l .
          ?s isoT:hasIdentifier/isoI:semanticVersion ?sv .
          ?s isoT:hasIdentifier/isoI:versionLabel ?vl .
          ?s isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?owner .
          ?s rdf:type ?rdf_type
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bo, :isoT, :isoC, :isoI])
      triples = query_results.by_object_set([:s, :i, :l, :sv, :vl, :owner, :rdf_type])
      triples.each do |x|
        results << {uri: x[:s].to_s, id: x[:s].to_id, identifier: x[:i], label: x[:l], semantic_version: x[:sv], version_label: x[:vl], owner: x[:owner], rdf_type: x[:rdf_type].to_s}
      end
      results
    end

  private

    # New association
    #
    # @param semantic [String] the string to define the association type
    # @return [Association] the new object. May contain errros if unsuccesful
    def new_association(params)
      association = Association.new({the_subject: self, semantic: params[:semantic]})
      association.uri = association.create_uri(Association.base_uri)
      association
    end

  end

end