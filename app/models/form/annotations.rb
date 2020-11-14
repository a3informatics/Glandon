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
      @domain_list = {}
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
        {annotation_set: @annotation_set.map{|k,v| v.to_h}, domain_list: @domain_list}
      end

    end

  private

    # BC Annotations
    #
    # @return [Array] Array of annotation objects
    def bc_annotations
      query_string = %Q{
        SELECT ?item ?domain ?sdtm_var_name ?sdtm_topic_name ?sdtm_topic_sub ?domain_long_name WHERE
        { 
          ?topic_var bd:hasProperty ?op_ref3 . 
          ?op_ref3 bo:hasProperty ?bc_topic_property .     
          ?bc_root (bc:hasProperty|bc:hasDatatype|bc:hasItem|bc:hasComplexDatatype) ?bc_topic_property .
          ?bc_topic_property bc:hasThesaurusConcept ?value_ref .
          ?value_ref bo:hasThesaurusConcept ?sdtm_topic_value_obj . 
          #?sdtm_topic_value_obj iso25964:notation ?sdtm_topic_sub .
          {         
            SELECT ?form ?group ?item ?bc_property ?bc_root ?bc_ident ?sdtm_var_name ?domain ?sdtm_topic_name ?topic_var ?domain_long_name WHERE 
            {   
              ?var bd:name ?sdtm_var_name .              
              ?dataset bd:includesColumn ?var .              
              ?dataset bd:prefix ?domain .
              ?dataset isoC:label ?domain_long_name .
              ?dataset bd:includesColumn ?topic_var .             
              ?topic_var bd:classifiedAs ?classification .             
              ?classification rdfs:label \"Topic\"^^xsd:string .              
              ?topic_var bd:name ?sdtm_topic_name . 
              {
                SELECT ?group ?item ?bc_property ?bc_root ?bc_ident ?sdtm_var_name ?dataset ?var ?gord ?pord WHERE 
                { 
                  #{@form.uri.to_ref} (bf:hasGroup|bf:hasSubGroup|bf:hasCommon) ?group .
                  ?group bf:ordinal ?gord .
                  ?group bf:hasItem ?item .
                  ?item bf:hasProperty ?op_ref1 .
                  ?op_ref1 bo:reference ?bc_property .
                  ?op_ref2 bo:reference ?bc_property .
                  ?var bd:hasProperty ?op_ref2 .
                    ?bc_root (bc:hasProperty|bc:hasDatatype|bc:hasItem|bc:hasComplexDatatype) ?bc_property .
                    ?bc_root rdf:type bc:BiomedicalConceptInstance .
                    ?bc_property bc:ordinal ?pord .      
                    ?bc_root isoT:hasIdentifier ?si .     
                    ?si isoI:identifier ?bc_ident .
                }
              }
            }
          }
        } ORDER BY ?gord ?pord
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoT, :isoI, :isoC])
      triples = query_results.by_object_set([:item, :domain, :sdtm_var_name, :domain_long_name, :sdtm_topic_name, :sdtm_topic_sub])
      triples.each do |entry|
        add_annotation(entry)
      end
    end

    # Item Annotations
    #
    # @return [Array] Array of annotation objects
    def item_annotations
      query_string = %Q{         
        SELECT DISTINCT ?sdtm_var_name ?domain ?item ?domain_long_name WHERE 
        {
          ?col bd:name ?sdtm_var_name .
          ?dataset bd:includesColumn ?col .
          ?dataset bd:prefix ?domain .
          ?dataset isoC:label ?domain_long_name .
          { 
            SELECT ?group ?item ?sdtm_var_name ?gord ?pord WHERE
            { 
              #{@form.uri.to_ref} (bf:hasGroup|bf:hasSubGroup) ?group .
              ?group bf:ordinal ?gord .
              ?group (bf:hasItem)+ ?item .
              ?item bf:mapping ?sdtm_var_name .
              ?item bf:ordinal ?pord .
            }
          }
        } ORDER BY ?gord ?pord
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc, :isoC])
      triples = query_results.by_object_set([:item, :domain, :sdtm_var_name, :domain_long_name])
      triples.each do |entry|
        add_annotation(entry)
      end
    end

    def add_annotation(entry)
      uri = entry[:item].to_s
      entry[:sdtm_topic_name].nil? ? entry[:sdtm_topic_name] = "" : entry[:sdtm_topic_name]
      entry[:sdtm_topic_sub].nil? ? entry[:sdtm_topic_sub] = "" : entry[:sdtm_topic_sub]
      @annotation_set[uri] = Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name: entry[:domain_long_name], sdtm_variable:entry[:sdtm_var_name], sdtm_topic_variable: entry[:sdtm_topic_name], sdtm_topic_value: entry[:sdtm_topic_sub] })
    end

    def set_domain_prefix_and_long_name(annotation)
      domain_prefix = annotation.domain_prefix.to_sym
      domain_long_name = annotation.domain_long_name
      @domain_list[domain_prefix] = {long_name: domain_long_name} if !@domain_list.key?(domain_prefix)
    end

  end

end