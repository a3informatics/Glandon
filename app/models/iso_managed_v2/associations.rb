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
    def associate(ids, semantic)
      association = self.association? ? Association.find(self.association)  : new_association(the_subject: self.uri, semantic: semantic)
      association.associated_with = ids.map{|x| Uri.new(id: x)}
      association.save
      association
    end

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

    def diassociate_all
      association = self.association? ? Association.find(self.association) : self.errors.add(:base, "Failed to find association")
      association.delete
      1
    end

    # Association?
    #
    # @result [Boolean] return true if exists an assocation
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

    # Remove Links. 
    #
    # @param 
    # @return
    def remove_links(ids)
      # transaction_begin
      # uris = ids.map{|x| Uri.new(id: x[:id])}
      # uris.each do |uri| 
      #   self.remove_link(:associated_with, uri)
      # end
      # transaction_execute
    end

  end

end