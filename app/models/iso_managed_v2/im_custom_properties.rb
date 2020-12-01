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

    # Populate Custom Properties. Load all the properties for the managed item
    #
    # @return [Void] no return
    def populate_custom_properties
      self.load_custom_properties
      self.children.each do |child|
        child.load_custom_properties(self)
      end
    end

    # Load Custom Properties. Load the custom property values for this object, if any
    #
    # @param [object] contaxt the context, defaults to self
    # @return [IsoConceptV2::CustomPropertySet] class instance holding the set of properties
    def load_custom_properties(context=self)
      super
    end

    # Find Custom Property Values
    #
    # @return [Hash] hash, keyed by id of the custom properties
    def find_custom_property_values
      results = {}
      query_string = %Q{
        SELECT ?e ?c ?l ?v WHERE 
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
      query_results.by_object_set([:e, :c, :l, :v]).each do |x|
        id = x[:c].to_id
        results[id] = {item_id: id} unless results.key?(id)
        inner_key = x[:l].to_variable_style.to_sym
        results[id][inner_key] = {} unless results[id].key?(inner_key)
        results[id][inner_key][:id] = x[:e].to_id
        results[id][inner_key][:value] = x[:v]
      end
      results.values
    end

    # Add Custom Property Context.
    #
    # @param [Array] uris_or_ids array of uris or ids of the items for which the custom properties are to be updated
    # @param [Object|Uri] context the new context, either an object or a uri
    # @return [Boolean] true 
    def add_custom_property_context(uris_or_ids)
      update_query = %Q{ 
        INSERT 
        { 
          ?e isoC:context #{self.uri.to_ref} . 
        }
        WHERE 
        { 
          VALUES ?s { #{uris_or_ids.map{|x| self.class.as_uri(x).to_ref}.join(" ")} }
          ?e isoC:appliesTo ?s . 
          ?e rdf:type isoC:CustomProperty .
        }
      }      
      partial_update(update_query, [:isoC])
      true
    end

  end

end