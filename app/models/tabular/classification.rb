class Tabular::Classification
  
  # Constants
  C_CLASS_NAME = self.name

  extend ActiveModel::Naming

  # Initialize
  #
  # @return [Void] no return
  def initialize
    @set = Tabular::Collection.new(klass: SdtmModelClassification)
  end

  # Add
  #
  # @return [Void] no return
  def self.add(classification, sub_classification)
    return if classification.nil?
    add_parent_child(classification, sub_classification)
  end

private

  # Build classification
  def self.add_parent_child(classification, sub_classification)
    parent = @set.add(classification)
    parent.set_parent
    return if sub_classification.nil?
    return if sub_classification == SdtmModel::Variable::C_ROLE_Q_NA 
    child = @set.add(sub_classification) 
    parent.add_child(child)
  end

  # Match
  #
  # @param [Stirng] label the label to be matched
  # @return [Object] the object matching the label or nil.
  def match(label)
    return @set.match(label)
  end

  # Test only
  #
  if Rails.env.test?
    def set
      @set
    end
  end

end