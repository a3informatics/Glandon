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

    # ----------------
    # Instance Methods
    # ----------------

    # Find Custom Property Definitions. Find the custom property definitions for a specified klass
    #
    # @return [Array] array of CustomPropertyDefinition objects
    def find_custom_property_definitions
        results = []
        query_string = %Q{
          SELECT DISTINCT ?s ?p ?o WHERE 
          {            
            #{self.uri.to_ref} #{self.class.children_predicate.to_ref} ?c .
            ?c ^isoC:appliesTo/isoC:customPropertyDefinedBy ?s .
            ?s rdf:type isoC:CustomPropertyDefinition .
            ?c rdf:type ?rc .
            ?s isoC:customPropertyOf ?rc .
            ?s ?p ?o
          }   
        }
        query_results = Sparql::Query.new.query(query_string, "", [:isoC])
        query_results.by_subject.each do |subject, triples|
          results << CustomPropertyDefinition.from_results(Uri.new(uri: subject), triples)
        end
        results
    end

    # Find Custom Property Definitions To H. Find the custom property definitions for a specified klass as a hash
    #
    # @return [Array] array of hash
    def find_custom_property_definitions_to_h
        results = find_custom_property_definitions
        results = results.map{|x| x.to_h.slice(:id, :datatype, :label).merge({name: x.label_to_variable})}
        results.sort { |a, b| [b[:datatype], a[:name]] <=> [a[:datatype], b[:name]] }
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
        SELECT ?e ?c ?l ?v ?dt WHERE 
        {            
          #{self.uri.to_ref} #{self.class.children_predicate.to_ref} ?c .
          ?e rdf:type isoC:CustomProperty .
          ?e isoC:appliesTo ?c .          
          ?e isoC:context #{self.uri.to_ref} . 
          ?e isoC:customPropertyDefinedBy ?d .
          ?d isoC:label ?l .
          ?d isoC:datatype ?dt .
          ?e isoC:value ?v .
        } ORDER BY ?c ?l   
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC])
      query_results.by_object_set([:e, :c, :l, :v, :dt]).each do |x|
        id = x[:c].to_id
        results[id] = {item_id: id} unless results.key?(id)
        inner_key = x[:l].to_variable_style.to_sym
        results[id][inner_key] = {} unless results[id].key?(inner_key)
        results[id][inner_key][:id] = x[:e].to_id
        dt = XSDDatatype.new(x[:dt])
        results[id][inner_key][:value] = dt.to_typed(x[:v])
      end
      results.values
    end

    # Add Custom Property Context.
    #
    # @param [Array] uris_or_ids array of uris or ids of the items for which the custom properties are to be updated
    # @return [Boolean] true 
    def add_custom_property_context(uris_or_ids)
      return true if uris_or_ids.empty?
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

    # Existing Custom Property Set. The set of uris that [may] contain custom properties
    #   THis version should be overloaded as needed by application classes.
    #
    # @param [object] contaxt the context, defaults to self
    # @return [Array] array of URIs for items having context. Always empty.
    def existing_custom_property_set
      []
    end

    # Missing Custom Properties
    #
    # @param [Array] uris_or_ids array of uris or ids of the items for which the custom properties are to be updated
    # @param [Class] klass klass for the definitions
    # @return [Array] array of hash containing subject definition pairs
    def missing_custom_properties(uris_or_ids, klass)
      query_string = %Q{ 
        SELECT DISTINCT ?subject ?definition WHERE
        { 
          VALUES ?subject { #{uris_or_ids.map{|x| self.class.as_uri(x).to_ref}.join(" ")} }
          ?definition rdf:type isoC:CustomPropertyDefinition .
          ?d isoC:customPropertyOf #{klass.rdf_type.to_ref} .
          FILTER ( NOT EXISTS {?subject ^isoC:appliesTo/isoC:customPropertyDefinedBy ?definition})
        }
      }      
      query_results = Sparql::Query.new.query(query_string, "", [:isoC])
      query_results.by_object_set([:subject, :definition])
    end

    # Add Missing Custom Properties
    #
    # @param [Array] uris_or_ids array of uris or ids of the items for which the custom properties are to be updated
    # @param [Class] klass klass for the definitions
    # @param [Sparql::Transaction] tx the transaction, defaults to nil
    # @return [Boolean] true
    def add_missing_custom_properties(uris_or_ids, klass, tx=nil)
      items = missing_custom_properties(uris_or_ids, klass)
      definitions = klass.find_custom_property_definitions
      items.each do |item|
        definition = definitions.find{|x| x.uri == item[:definition]}
        self.custom_properties << CustomPropertyValue.create(parent_uri: CustomPropertyValue.base_uri, transaction: tx, 
          value: definition.default, custom_property_defined_by: definition.uri, applies_to: item[:subject], context: [self.uri])
      end
      true
    end

  end

end