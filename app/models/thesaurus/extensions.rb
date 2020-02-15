# Managed Concepts
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Extensions

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Can extend unextensible?
      #
      # @return [Boolean] true if can extend an unextensible managed concept
      def can_extend_unextensible?
        extensions_configuration[:can_extend_unextensible]
      end

    private
      
      def extensions_configuration
        Rails.configuration.thesauri[:extensions]
      end

    end

  end

end