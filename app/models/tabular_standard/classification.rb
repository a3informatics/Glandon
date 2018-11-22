class TabularStandard::Classification < TabularStandard::Collection
  
    # Constants
  C_CLASS_NAME = self.name

  # Initialize
  #
  # @return [Void] no return
  def initialize
   super(klass: ::SdtmModelClassification)
  end

  # Add
  #
  # @return [Void] no return
  def self.add(classification, sub_classification)
    return if classification.nil?
    add_parent_child(classification, sub_classification)
  end

private

  # Setup parent child
  def self.add_parent_child(classification, sub_classification)
    parent = @set.add(classification)
    parent.set_parent
    return if sub_classification.nil?
    return if sub_classification == SdtmModel::Variable::C_ROLE_Q_NA 
    child = @set.add(sub_classification) 
    parent.add_child(child)
  end

end