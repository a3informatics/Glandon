# Custom Properties. Module to handle custom properties
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoConceptV2
  
  module CustomProperties

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Empty at present
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

    def custom_properties_diff?(previous)
      self.custom_properties.diff?(previous.custom_properties)
    end

  end

end