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
      @annotation_set = {}
      bc_annotations 
      item_annotations
      @domain_list = domain_list
    end

    # Annotation for uri
    #
    # @param [Uri] uri the uri of the object 
    # @return [Object] Annotation or nil if there is no match 
    def annotation_for_uri(uri)
      @annotation_set.key?(uri) ? @annotation_set[uri] : nil
    end

    # Domain list
    #
    # @return [Hash] Hash of domains, keyed by prefix
    def domain_list
      result = {}
      @annotation_set.each do |uri, annotation|
        set_domain_prefix_and_long_name(annotation, result)
      end
      result
    end

    def add_domain_class(domain_class)

    end

    # ---------
    # Test Only  
    # ---------

    if Rails.env.test?

      def to_h
        {annotation_set: @annotation_set.map{|k,v| v.to_h}, domain_list: @domain_list}
      end

    end

  private

    # BC Annotations
    #
    # @return [Array] Array of annotation objects
    def bc_annotations
      query_string = %Q{
        SELECT ?item ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub ?domain_long_name WHERE
        { 
          ?topic_var bd:hasProperty ?op_ref3 . 
          ?op_ref3 bo:hasProperty ?bc_topic_property .     
          ?bc_root (bc:hasProperty|bc:hasDatatype|bc:hasItem|bc:hasComplexDatatype) ?bc_topic_property .
          ?bc_topic_property bc:hasThesaurusConcept ?valueRef .
          ?valueRef bo:hasThesaurusConcept ?sdtmTopicValueObj . 
          #?sdtmTopicValueObj iso25964:notation ?sdtmTopicSub .
          {         
            SELECT ?form ?group ?item ?bcProperty ?bc_root ?bcIdent ?sdtmVarName ?domain ?sdtmTopicName ?topic_var ?domain_long_name WHERE 
            {   
              ?var bd:name ?sdtmVarName .              
              ?dataset bd:includesColumn ?var .              
              ?dataset bd:prefix ?domain .
              ?dataset isoC:label ?domain_long_name .
              ?dataset bd:includesColumn ?topic_var .             
              ?topic_var bd:classifiedAs ?classification .             
              ?classification rdfs:label \"Topic\"^^xsd:string .              
              ?topic_var bd:name ?sdtmTopicName . 
              {
                SELECT ?group ?item ?bc_property ?bc_root ?bc_ident ?sdtm_var_name ?dataset ?var ?gord ?pord WHERE 
                { 
                  #{@form.uri.to_ref} (bf:hasGroup|bf:hasSubGroup|bf:hasCommon) ?group .
                  ?group bf:ordinal ?gord .
                  ?group bf:hasItem ?item .
                  ?item bf:hasProperty ?op_ref1 .
                  ?op_ref1 bo:reference ?bcProperty .
                  ?op_ref2 bo:reference ?bcProperty .
                  ?var bd:hasProperty ?op_ref2 .
                    ?bc_root (bc:hasProperty|bc:hasDatatype|bc:hasItem|bc:hasComplexDatatype) ?bcProperty .
                    ?bc_root rdf:type bc:BiomedicalConceptInstance .
                    ?bcProperty bc:ordinal ?pord .      
                    ?bc_root isoT:hasIdentifier ?si .     
                    ?si isoI:identifier ?bcIdent .
                }
              }
            }
          }
        } ORDER BY ?gord ?pord
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoT, :isoI, :isoC])
      triples = query_results.by_object_set([:item, :domain, :sdtmVarName, :sdtmTopicName, :sdtmTopicSub, :domain_long_name])
      triples.each do |entry|
        uri = entry[:item].to_s
        @annotation_set[uri] = Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name: entry[:domain_long_name], sdtm_variable: entry[:sdtmVarName], sdtm_topic_variable: entry[:sdtmTopicName], sdtm_topic_value: entry[:sdtmTopicSub]})
        
      end
    end

    # Item Annotations
    #
    # @return [Array] Array of annotation objects
    def item_annotations
      query_string = %Q{         
        SELECT DISTINCT ?var ?domain ?item ?domain_long_name WHERE 
        {
          ?col bd:name ?var .
          ?dataset bd:includesColumn ?col .
          ?dataset bd:prefix ?domain .
          ?dataset isoC:label ?domain_long_name .
          { 
            SELECT ?group ?item ?var ?gord ?pord WHERE
            { 
              #{@form.uri.to_ref} (bf:hasGroup|bf:hasSubGroup) ?group .
              ?group bf:ordinal ?gord .
              ?group (bf:hasItem)+ ?item .
              ?item bf:mapping ?var .
              ?item bf:ordinal ?pord .
            }
          }
        } ORDER BY ?gord ?pord
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoC])
      triples = query_results.by_object_set([:item, :domain, :var, :domain_long_name])
      triples.each do |entry|
        uri = entry[:item].to_s
        @annotation_set[uri] = Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name: entry[:domain_long_name], sdtm_variable:entry[:var], sdtm_topic_variable: "", sdtm_topic_value: "" })
      end
    end

    # def add_annotation(entry)
    #   uri = entry[:item].to_s
    #   @annotation_set[uri] = Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name: entry[:domain_long_name], sdtm_variable:entry[:var], sdtm_topic_variable: "", sdtm_topic_value: "" })
    # end

    def set_domain_prefix_and_long_name(annotation, result)
      domain_prefix = annotation.domain_prefix.to_sym
      domain_long_name = annotation.domain_long_name
      result[domain_prefix] = domain_long_name if !result.key?(domain_prefix)
    end

  end

end