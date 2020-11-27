# Custom Properties. Module to handle custom properties
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoConceptV2
  
  module IcCustomProperties

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Find Custom Property Definitions. Find the custom property definitions for a specified klass
      #
      # @return [Array] array of CustomPropertyDefinition objects
      def find_custom_property_definitions(klass)
        results = []
        query_string = %Q{
          SELECT ?s ?p ?o WHERE 
          {            
            ?s rdf:type isoC:CustomPropertyDefinition .
            ?s isoC:customPropertyOf #{klass.rdf_type.to_ref} .
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
      def find_custom_property_definitions_to_h(klass)
        results = find_custom_property_definitions(klass)
        results = results.map{|x| x.to_h.slice(:id, :datatype, :label).merge({name: x.label.to_variable_style})}
        results.sort { |a, b| [b[:datatype], a[:name]] <=> [a[:datatype], b[:name]] }
      end

      # Custom Properties? Does the object have custom properties set (note this is defined not data values present)
      #
      # @return [Boolean] true if data present, false otherwise
      def custom_properties?
        Sparql::Query.new.query("ASK {#{self.rdf_type.to_ref} ^isoC:customPropertyOf ?o}", "", [:isoC]).ask? 
      end

    end

    # Custom Properties? Does the object have custom properties set (note this is defined not data values present)
    #
    # @return [Boolean] true if data present, false otherwise
    def custom_properties?
      self.class.custom_properties?
    end

    def create_custom_properties(new_object, tx=nil, context=self)
      definitions = find_custom_property_definitions(new_object.class)
      return if properties.empty?
      definitions.each do |definition|
        new_onject.custom_properties << CustomPropertyValue.create(parent_uri: CustomPropertyValue.base_uri, transaction: tx, 
          value: definition.default, custom_property_defined_by: definition.uri)
      end
      new_object.custom_properties
    end

    def clone_custom_properties(new_object, context=self)
      context_uri = context.is_a?(Uri) ? context : context.uri
      properties = load_custom_properties(context)
      properties.each do |property|
        if property_multiple_contexts_include?(property, context_uri)
          property.applies_to = new_object
          new_object.custom_properties << property
        else
          object = property.clone
          object.context = [context_uri]
          object.applies_to = new_object
          new_object.custom_properties << object
        end
      end
      new_object.custom_properties
    end

    # Load Custom Properties. Load the custom property values for this object, if any
    #
    # @param [object] contaxt the context
    # @return [IsoConceptV2::CustomPropertySet] class instance holding the set of properties
    def load_custom_properties(context=self)
      @custom_properties = IsoConceptV2::CustomPropertySet.new
      query_string = %Q{
        SELECT ?s ?p ?o ?e WHERE 
        {            
          ?e rdf:type isoC:CustomProperty .
          ?e isoC:appliesTo #{self.uri.to_ref} .          
          ?e isoC:context #{context.uri.to_ref} . 
          {             
            ?e isoC:customPropertyDefinedBy ?s .
            ?s ?p ?o .             
          }           
          UNION           
          {             
            BIND (?e as ?s)
            ?e ?p ?o .          
          }         
        }   
      }
      results = Sparql::Query.new.query(query_string, "", [:isoC])
      results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
        @custom_properties << ::CustomPropertyValue.from_results_recurse(uri, results.by_subject)
      end
      @custom_properties
    end

    # Custom Properties Getter. Return the custom property values for this object
    #
    # @return [IsoConceptV2::CustomPropertySet] class instance holding the set of properties. Can be empty.
    def custom_properties
      @custom_properties
    end

    # Custom Properties Setter. Only really useful in copying of objects
    #
    # @return [Void] no return
    def custom_properties=(value)
      @custom_properties = value
    end

    # Custom Properties Diff. Custom Properties in object different to another object's properties
    #
    # @return [Boolean] true if different, false otherwise
    def custom_properties_diff?(previous)
      self.custom_properties.diff?(previous.custom_properties)
    end

  private

    def property_multiple_contexts_include?(property, context)
      contexts = property.context.map{|x| x.uri.to_s}
      return context.count > 1 && contexts.include?(context_uri)
    end

  end

end