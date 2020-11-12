# Form Annotations. Class to handle annotations
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class Form

  class Annotations

    # Initialize
    #
    # @param [Object] form the form object 
    # @return [] 
    def initialize(form)
      form.bc_annotations
      form.question_annotations
    end

  
    def bc_annotations
      query_string = %Q{         
        SELECT ?group ?item ?bc_property ?bc_root ?bc_ident ?sdtm_var_name ?dataset ?var ?gord ?pord WHERE 
        { #{self.uri.to_ref} (bf:hasGroup|bf:hasSubGroup|bf:hasCommon) ?group .
          ?group bf:ordinal ?gord .
          ?group (bf:hasItem) ?item .
          ?item bf:hasProperty ?op_ref1 .
          ?op_ref1 bo:reference ?bcProperty .
          ?op_ref2 bo:reference ?bcProperty .
          ?var bd:hasProperty ?op_ref2 .
        }
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:normal_group).first
    end


  end

end