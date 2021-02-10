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
    # @param [Array] uris_or_ids array of hashes of items for which the custom properties are to be updated and their contexts
    # @return [Boolean] true 
    def add_custom_property_context(uris_or_ids)
      return true if uris_or_ids.empty?
      pairs = uris_or_ids.map{|x| {applies_to: self.class.as_uri(x[:id]), context: self.class.as_uri(x[:context_id])}}
      update_query = %Q{ 
        INSERT 
        { 
          ?e isoC:context #{self.uri.to_ref} . 
        }
        WHERE 
        { 
          VALUES (?s ?c) {#{pairs.map{|x| "( #{x[:applies_to].to_ref} #{x[:context].to_ref} )" }.join(" ")}}
          ?e isoC:appliesTo ?s . 
          ?e rdf:type isoC:CustomProperty .
          ?e isoC:context ?c . 
        }
      }      
      partial_update(update_query, [:isoC])
      true
    end

    # Full Contexts. Construct hash of ids and context ids from existing set
    #
    # @return [Array] array of hashes each containing the id and the context id
    def full_contexts(uris_or_ids)
      uris_or_ids.map{|x| {id: x, context_id: self.id}}
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
    # @param [Array] uris_or_ids array of hashes of items for which the custom properties are to be updated and their contexts
    # @param [Class] klass klass for the definitions
    # @return [Array] array of hash containing subject definition pairs
    def missing_custom_properties(uris_or_ids, klass)
      return [] if uris_or_ids.empty?
      pairs = uris_or_ids.map{|x| {applies_to: self.class.as_uri(x[:id]), context: self.class.as_uri(x[:context_id])}}
      query_string = %Q{ 
        SELECT DISTINCT ?subject ?definition WHERE
        { 
          VALUES (?subject ?context) {#{pairs.map{|x| "( #{x[:applies_to].to_ref} #{x[:context].to_ref} )" }.join(" ")}}
          ?definition rdf:type isoC:CustomPropertyDefinition .           
          ?definition isoC:customPropertyOf #{klass.rdf_type.to_ref} .
          FILTER ( NOT EXISTS {
            ?cpv isoC:appliesTo ?subject .
            ?context ^isoC:context ?cpv .
            ?cpv rdf:type isoC:CustomProperty . 
            ?cpv isoC:customPropertyDefinedBy ?definition
          })  
        } ORDER BY ?subject ?definition
      }      
      query_results = Sparql::Query.new.query(query_string, "", [:isoC])
      query_results.by_object_set([:subject, :definition])
    end

    # Add Missing Custom Properties
    #
    # @param [Array] uris_or_ids array of hashes of items for which the custom properties are to be updated and their contexts
    # @param [Class] klass klass for the definitions
    # @param [Sparql::Transaction] tx the transaction, defaults to nil
    # @return [Boolean] true
    def add_missing_custom_properties(uris_or_ids, klass, tx=nil)
      return true if uris_or_ids.empty?
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