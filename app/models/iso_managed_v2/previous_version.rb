# ISO Managed Previous Version. Methods to handle previous versions
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class IsoManagedV2
  
  module PreviousVersion

    # Replace If No Change. Replace the current with the previous if no differences.
    #
    # @param [IsoManagdV2] previous the previous item
    # @return [IsoManagedV2] the new object if changes, otherwise the previous object
    def replace_if_no_change(previous, ignore_properties=[])
      return self if previous.nil?
      return previous if !self.diff?(previous, {ignore: [:has_state, :has_identifier, :origin, :change_description,
        :creation_date, :last_change_date, :explanatory_comment, :tagged] + ignore_properties})
      replace_children_if_no_change(previous)
      self
    end

  private

    # Replace children if no change
    def replace_children_if_no_change(previous)
      self.children.each_with_index do |child, index|
        previous_child = previous.children.select {|x| x.key_property_value == child.key_property_value}
        next if previous_child.empty?
        self.children[index] = child.replace_if_no_change(previous_child.first)
      end
    end
    
  end

end