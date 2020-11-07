# Custom Properties. Module to handle custom properties
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoManagedV2
  
  module CustomProperties

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Empty at present
    end

    def find_custom_properties
      self.find_custom_properties
      self.class.children_predicate.each do |child|
        child.find_custom_properties(self)
      end
    end

  end

end