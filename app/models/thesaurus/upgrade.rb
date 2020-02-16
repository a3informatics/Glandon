# Managed Concepts Extensions
#
# @author Dave Iberson-Hurst
# @since 2.34.0
class Thesaurus

  module Uprade

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # Upgrade. Upgrade the Managed Concept to refer to the new reference. Adjust references accordingly
    #
    # - For an extension this will be all the children of the new reference plus the extending items
    # already present
    #
    # - For a subset this will be the current subset but only those item that are present in the new source
    #
    # @param new_reference [Thesurus::ManagedConcept] the new reference
    # @return [Void] no return
    def upgrade(new_reference)
      return upgrade_extension(new_reference) if self.extension?
      return upgrade_subset(new_reference) if self.subset?
    end

  private
      
    def upgrade_extension(new_reference)
    end

    def upgrade_subset(new_reference)
    end
    
  end

end