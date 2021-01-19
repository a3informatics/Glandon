# ISO Managed Association. Methods to handle associations
#
# @author 
# @since 
class IsoManagedV2
  
  module Associations

    # Associate. 
    #
    # @param [Array] ids set the ids to add as associated
    # @return [Association] new association or existing one with associated links
    def associate(ids)
      association = self.association? ? self.association : create_association({parent_uri: self.uri, the_subject: self.uri, semantic: "BC SDTM Assoc"})
      association.add_links(ids)
      association
    end

    def diassociate(ids)
      self.association.remove_links(ids)
      self.association
    end

    def diassociate_all
      self.association.delete_with_links
    end

    # Association?
    #
    # @result [Boolean] return true if exists an assocation
    def association?
      Sparql::Query.new.query("ASK {#{self.uri.to_ref} (^bo:theSubject) ?o}", "", [:bo]).ask? 
    end

    def association
      query_results = Sparql::Query.new.query("SELECT ?assoc WHERE {?assoc bo:theSubject #{self.uri.to_ref}}", "", [:bo])
      query_results.by_object_set([:association])
    end

    # Associated. 
    #
    # @param 
    # @return
    def associated
      result = []
      query_string = %Q{
        SELECT DISTINCT ?object ?object_label WHERE {
          #{self.uri.to_ref} bo:associatedWith ?object .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bo])
      triples = query_results.by_object_set([:object, :object_label])
      triples.each do |associated|
        result << {id: associated[:object].to_id, label: associated[:object_label]}
      end
      result
    end

    # Add Links. 
    #
    # @param 
    # @return 
    def add_links(ids)
      transaction_begin
      self.associated_with = ids.map{|x| Uri.new(id: x)}
      self.save
      transaction_execute
    end

  private

    # Create
    #
    # @param params [Hash] parameters for the class
    # @param parent [Object] the parent object, used for building the URI of the reference
    # @return [Association] the new object. May contain errros if unsuccesful
    def self.create(params, parent)
      params[:parent_uri] = parent.uri
      super(params)
    end

    # Create
    #
    # @param params [Hash] parameters for the class
    # @param parent [Object] the parent object, used for building the URI of the reference
    # @return [Association] the new object. May contain errros if unsuccesful
    def create_association(params)
      association = Association.create({the_subject: self, semantic: params[:semantic], parent_uri: params[:parent_uri]})
    end

    # Remove Links. 
    #
    # @param 
    # @return
    def remove_links(ids)
      transaction_begin
      uris = ids.map{|x| Uri.new(id: x[:id])}
      uris.each do |uri| 
        self.remove_link(:associated_with, uri)
      end
      transaction_execute
    end

  end

end