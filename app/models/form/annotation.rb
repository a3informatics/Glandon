# Form Annotations. Class to handle an annotation
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class Form

  class Annotation

    # Initialize the object
    #
    # @param [Uri] uri  
    # @return []
    def initialize(uri, domain_prefix, domain_long_name, sdtm_variable, sdtm_topic_variable, sdtm_topic_value)
      @uri = uri
      @domain_prefix = domain_prefix
      @domain_long_name = domain_long_name
      @sdtm_variable = sdtm_variable
      @sdtm_topic_variable = sdtm_topic_variable
      @sdtm_topic_value = sdtm_topic_value
    end

  end

end