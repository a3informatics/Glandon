# Form Annotations. Class to handle annotations
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class Form

  class Annotations

    # Initialize
    #
    # @param [Object] form the form object 
    # @return [Object] 
    def initialize(form)
      @form = form
      @annotation_set = Hash.new{|h,k| h[k] = [] }
      bc_annotations 
      item_annotations
      @domain_list = {}
    end

    # Annotation for uri
    #
    # @param [Uri] uri the uri of the object 
    # @return [Array] Array of Annotation or an empty array if there is no match 
    def annotation_for_uri(uri)
      @annotation_set.key?(uri) ? @annotation_set[uri] : []
    end

    # Domain list
    #
    # @return [Hash] Hash of domains, keyed by prefix
    def domain_list
      @annotation_set.each do |uri, annotation|
        set_domain_prefix_and_long_name(annotation)
      end
      @domain_list
    end

    def preserve_domain_class(domain_prefix, domain_class)
      @domain_list[domain_prefix][:domain_class] = domain_class
    end

    def retrieve_domain_class(domain_prefix)
      @domain_list[domain_prefix][:domain_class]
    end

    # ---------
    # Test Only  
    # ---------

    if Rails.env.test?

      def to_h
        annotations = Hash.new{|h,k| h[k] = [] }
        @annotation_set.each{|k,v| annotations[k] = v.map{|x| x.to_h}}
        {annotation_set: annotations, domain_list: @domain_list}
      end

    end

  private

    # BC Annotations
    #
    # @return [Array] Array of annotation objects
    def bc_annotations
      query_string = %Q{
        SELECT ?item ?domain_prefix ?sdtm_var_name ?domain_long_name ?sdtm_topic_name ?sdtm_topic_sub WHERE              
        {     
          ?sdtm_domain bd:basedOnClass/bd:includesColumn ?topic_var .                          
          ?topic_var bd:classifiedAs/isoC:prefLabel "Topic"^^xsd:string .
          ?sdtm_domain bd:includesColumn ?sdtm_topic_var .                          
          ?sdtm_topic_var bd:basedOnClassVariable ?topic_var .
          ?sdtm_topic_var bd:name ?sdtm_topic_name . 
          ?topic_var bd:isA ?canonical_reference .                          
          ?bc_root bc:identifiedBy/bc:hasComplexDatatype/bc:hasProperty ?bc_identifier .           
          ?bc_identifier bc:isA ?canonical_reference .             
          ?bc_identifier bc:hasCodedValue/bo:reference/th:notation ?sdtm_topic_sub .                      
          ?sdtm_domain bd:prefix ?domain_prefix .                                         
          ?sdtm_domain isoC:label ?domain_long_name .           
          {                                  
            SELECT ?item ?bc_root ?sdtm_domain_var ?sdtm_var_name ?sdtm_domain WHERE                  
            {                           
              #{@form.uri.to_ref} bf:hasGroup/bf:hasSubGroup* ?group .                                      
              ?group bf:ordinal ?gord .                                      
              ?group bf:hasItem ?item .
              ?item bf:ordinal ?pord .
              ?item bf:hasProperty ?op_ref1 .
              ?group bf:hasItem/bf:hasProperty ?op_ref1 .                                                     
              ?op_ref1 bo:reference ?bc_property .               
              ?bc_property bc:isA ?ref .                                                     
              ?sdtm_domain_var bd:isA ?ref .                                                     
              ?sdtm_domain_var bd:name ?sdtm_var_name .           
              ?sdtm_domain bd:includesColumn ?sdtm_domain_var .                                   
              ?sdtm_domain ^bo:associatedWith ?assoc .                                  
              ?bc_root ^bo:theSubject ?assoc .                                  
              ?bc_root (bc:hasItem/bc:hasComplexDatatype/bc:hasProperty) ?bc_property .         
            } ORDER BY ?gord ?pord                             
          }                          
        } 
      }   
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoT, :isoI, :isoC, :th])
      triples = query_results.by_object_set([:item, :domain_prefix, :sdtm_var_name, :domain_long_name, :sdtm_topic_name, :sdtm_topic_sub])
      triples.each do |entry|
        add_annotation(entry)
      end
    end

    # Item Annotations
    #
    # @return [Array] Array of annotation objects
    def item_annotations
      query_string = %Q{         
        SELECT DISTINCT ?item ?sdtm_var_name ?domain_prefix ?domain_long_name WHERE 
        {
          ?col bd:name ?sdtm_var_name .
          ?dataset bd:includesColumn ?col .
          ?dataset bd:prefix ?domain_prefix .
          ?dataset isoC:label ?domain_long_name .
          { 
            SELECT ?group ?item ?sdtm_var_name ?gord ?pord WHERE
            { 
              #{@form.uri.to_ref} bf:hasGroup/bf:hasSubGroup* ?group .                                                         
              ?group bf:ordinal ?gord .
              ?group (bf:hasItem)+ ?item .
              ?item bf:mapping ?sdtm_var_name .
              ?item bf:ordinal ?pord .
            }
          }
        } ORDER BY ?gord ?pord
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoC])
      triples = query_results.by_object_set([:item, :domain_prefix, :sdtm_var_name, :domain_long_name])
      triples.each do |entry|
        add_annotation(entry)
      end
    end

    def add_annotation(entry)
      uri = entry[:item].to_s
      entry[:sdtm_topic_name].nil? ? entry[:sdtm_topic_name] = "" : entry[:sdtm_topic_name]
      entry[:sdtm_topic_sub].nil? ? entry[:sdtm_topic_sub] = "" : entry[:sdtm_topic_sub]
      @annotation_set[uri] << Annotation.new({uri: uri, domain_prefix: entry[:domain_prefix], domain_long_name: entry[:domain_long_name], sdtm_variable:entry[:sdtm_var_name], sdtm_topic_variable: entry[:sdtm_topic_name], sdtm_topic_value: entry[:sdtm_topic_sub] })
    end

    def set_domain_prefix_and_long_name(annotation)
      annotation.each do |a|
        domain_prefix = a.domain_prefix.to_sym
        domain_long_name = a.domain_long_name
        @domain_list[domain_prefix] = {long_name: domain_long_name} if !@domain_list.key?(domain_prefix)
      end
    end

  end

end