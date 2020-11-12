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
    def initialize(params={})
      @uri = params[:uri]
      @domain_prefix = params[:domain_prefix]
      @domain_long_name = params[:domain_long_name]
      @sdtm_variable = params[:sdtm_variable]
      @sdtm_topic_variable = params[:sdtm_topic_variable]
      @sdtm_topic_value = params[:sdtm_topic_value]
    end

    # ---------
    # Test Only  
    # ---------

    if Rails.env.test?

      def to_h
        {uri: @uri.to_s, domain_prefix: @domain_prefix ,domain_long_name: @domain_long_name, sdtm_variable: @sdtm_variable, sdtm_topic_variable: @sdtm_topic_variable, sdtm_topic_value: @sdtm_topic_value}
      end

    end

  end

end