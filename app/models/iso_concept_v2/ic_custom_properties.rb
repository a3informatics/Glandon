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
        results.sort_by { |x| [ x[:datatype], x[:name] ] }
      end

    end

    def custom_properties?
      Sparql::Query.new.query("ASK {#{self.uri.rdf_type.to_ref} ^isoC:customPropertyOf ?o}", "", [:isoC]).ask? 
    end

    def find_custom_properties(context=self)
      @custom_properties = ::CustomPropertySet.new
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

    def custom_properties
      @custom_properties
    end

    def custom_properties=(value)
      @custom_properties = value
    end

    def custom_properties_diff?(previous)
      self.custom_properties.diff?(previous.custom_properties)
    end

  end

end