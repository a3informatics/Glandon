# ISO Managed. Handles the methods to create properties in the Managed class
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class IsoManagedV2
  
  module Resource

    def relationships(set)
      Errors.application_error(self.name, __method__.to_s, "Relationships needs to be an array.") if set.is_a?(Array)
      @configuration ||= {}
      @configuration[:relationships] = set
    end
    
  end

end