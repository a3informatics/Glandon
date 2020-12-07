# Thesaurus Custom Property
#
# @author Dave Iberson-Hurst
# @since 3.4.0
class Thesaurus

  module McCustomProperties

    # Existing Custom Property Set. The set of uris that [may] contain custom properties
    #
    # @param [object] contaxt the context, defaults to self
    # @return [Array] array of URIs for items having context
    def existing_custom_property_set
      self.narrower_links
    end

  end

end