# Managed Concepts Ranked. Handling for a Managed Concept that is ranked.
#
# @author Dave Iberson-Hurst
# @since 2.40.0
class Thesaurus

  module Ranked

    # Ranked? Is this item ranked
    #
    # @result [Boolean] return true if this instance is ranked
    def ranked?
      !self.is_ranked_links.nil?
    end

  end

end