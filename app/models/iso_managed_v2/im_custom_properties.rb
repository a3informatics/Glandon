# Custom Properties. Module to handle custom properties
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoManagedV2
  
  module ImCustomProperties

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Empty at present
    end

    def find_custom_properties
      self.find_custom_properties
      self.class.children_predicate.each do |child|
        child.find_custom_properties(self)
      end
    end

    # Find Custom Property Values
    #
    # @return [Hash] hash, keyed by id of the custom properties
    def find_custom_property_values
      results = {}
      query_string = %Q{
        SELECT ?c ?l ?v WHERE 
        {            
          #{self.uri.to_ref} #{self.class.children_predicate.to_ref} ?c .
          ?e rdf:type isoC:CustomProperty .
          ?e isoC:appliesTo ?c .          
          ?e isoC:context #{self.uri.to_ref} . 
          ?e isoC:customPropertyDefinedBy ?d .
          ?d isoC:label ?l .
          ?e isoC:value ?v .
        } ORDER BY ?c ?l   
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC])
      query_results.by_object_set([:c, :l, :v]).each do |x|
        id = x[:c].to_id
        results[id] = {id: id} unless results.key?(id)
        results[id][x[:l].to_variable_style] = x[:v]
      end
      results.values
    end

  end

end