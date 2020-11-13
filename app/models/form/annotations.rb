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
      @annotation_set = bc_annotations + item_annotations
      @domain_list = domain_list
    end

    # Annotation for uri
    #
    # @param [Uri] uri the uri of the object 
    # @return [Object] Annotation or nil if there is no match 
    def annotation_for_uri(uri)
      result = nil
      @annotation_set.each do |annotation|
        result = annotation if annotation.instance_variable_get(:@uri) == uri
      end
      result
    end

    # Domain list
    #
    # @return [Hash] Hash of domains, keyed by prefix
    def domain_list
      result = {}
      @annotation_set.each do |annotation|
        domain_prefix = annotation.instance_variable_get(:@domain_prefix)
        domain_long_name = annotation.instance_variable_get(:@domain_long_name)
        result[domain_prefix.to_sym] = domain_long_name
      end
      result
    end

    # ---------
    # Test Only  
    # ---------

    if Rails.env.test?

      def to_h
        {annotation_set: @annotation_set.map{|x| x.to_h}, domain_list: @domain_list}
      end

    end

  private

    # BC Annotations
    #
    # @return [Array] Array of annotation objects
    def bc_annotations
      results = []
      query_string = %Q{
        SELECT ?item ?domain ?sdtmVarName ?sdtmTopicName ?sdtmTopicSub WHERE
        { 
          ?topic_var bd:hasProperty ?op_ref3 . 
          ?op_ref3 bo:hasProperty ?bc_topic_property     
          ?bcRoot (bc:hasProperty|bc:hasDatatype|bc:hasItem|bc:hasComplexDatatype) ?bc_topic_property 
          ?bc_topic_property bc:hasThesaurusConcept ?valueRef 
          ?valueRef bo:hasThesaurusConcept ?sdtmTopicValueObj   
          ?sdtmTopicValueObj iso25964:notation ?sdtmTopicSub 
          {         
            SELECT ?form ?group ?item ?bcProperty ?bcRoot ?bcIdent ?sdtmVarName ?domain ?sdtmTopicName ?topic_var WHERE 
            {   
              ?var bd:name ?sdtmVarName .              
              ?dataset bd:includesColumn ?var .              
              ?dataset bd:prefix ?domain .              
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
                        ?bcRoot (bc:hasProperty|bc:hasDatatype|bc:hasItem|bc:hasComplexDatatype) ?bcProperty .
                        ?bcRoot rdf:type bc:BiomedicalConceptInstance .
                        ?bcProperty bc:ordinal ?pord .      
                        ?bcRoot isoT:hasIdentifier ?si .     
                        ?si isoI:identifier ?bcIdent .
                }
              }
            }
          }
        } ORDER BY ?gord ?pord
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoT, :isoI])
      triples = query_results.by_object_set([:item, :domain, :sdtmVarName, :sdtmTopicName, :sdtmTopicSub])
      triples.each do |entry|
        uri = entry[:item].to_s
        results << Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name: "domain_long_name", sdtm_variable: entry[:sdtmVarName], sdtm_topic_variable: entry[:sdtmTopicName], sdtm_topic_value: entry[:sdtmTopicSub]})
      end
      results
    end

    # Item Annotations
    #
    # @return [Array] Array of annotation objects
    def item_annotations
      results = []
      query_string = %Q{         
        SELECT DISTINCT ?var ?domain ?item WHERE 
        {
          ?col bd:name ?var .
          ?dataset bd:includesColumn ?col .
          ?dataset bd:prefix ?domain .
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
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc])
      triples = query_results.by_object_set([:var, :domain, :item])
      # if @@domain_map.has_key?(domain)
      #   domain_long_name = @@domain_map[domain]
      # end
      triples.each do |entry|
        uri = entry[:item].to_s
        results << Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name: "entry[:domain_long_name]", sdtm_variable:entry[:var], sdtm_topic_variable: "", sdtm_topic_value: "" })
      end
      results
    end


  end

end