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

    def bc_annotations
      results = []
      query_string = %Q{         
        SELECT ?group ?item ?bc_property ?bc_root ?bc_ident ?sdtm_var_name ?dataset ?var ?gord ?pord WHERE 
        { #{@form.uri.to_ref} (bf:hasGroup|bf:hasSubGroup|bf:hasCommon) ?group .
          ?group bf:ordinal ?gord .
          ?group bf:hasItem ?item .
          ?item bf:hasProperty ?op_ref1 .
          ?op_ref1 bo:reference ?bcProperty .
          ?op_ref2 bo:reference ?bcProperty .
          ?var bd:hasProperty ?op_ref2 .
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc])
      triples = query_results.by_object_set([:item, :domain, :sdtmVarName, :sdtmTopicName, :sdtmTopicSub])
      triples.each do |entry|
        uri = entry[:item].to_s
        #results[uri] = {domain_prefix: entry[:domain], children: []} if !results.key?(uri)
        #results << Annotation.new({uri: uri, domain_prefix: entry[:domain], domain_long_name:, sdtm_variable:sdtmVarName, sdtm_topic_variable:, sdtm_topic_value: })
      end
      results
    end

    def item_annotations
      results = []
      query_string = %Q{         
        SELECT ?group ?item ?bc_property ?bc_root ?bc_ident ?sdtm_var_name ?dataset ?var ?gord ?pord WHERE 
        { #{@form.uri.to_ref} (bf:hasGroup|bf:hasSubGroup|bf:hasCommon) ?group .
          ?group bf:ordinal ?gord .
          ?group (bf:hasItem) ?item .
          ?item bf:hasProperty ?op_ref1 .
          ?op_ref1 bo:reference ?bcProperty .
          ?op_ref2 bo:reference ?bcProperty .
          ?var bd:hasProperty ?op_ref2 .
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf, :bo, :bd, :bc])
      results
    end


  end

end