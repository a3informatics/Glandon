class Tabular::Datatype
  
  # Constants
  C_CLASS_NAME = self.name

  extend ActiveModel::Naming

  # Initialize
  #
  # @return [Void] no return
  def initialize
    @set = Tabular::Collection.new(klass: SdtmModelDatatype)
  end

  # Add. Will add the configured class and set the label if the label does not exist
  #  in the collection
  #
  # @param [Hash] hash containing a set of datatype labels
  # @return [Void] no return
  def add(json)
    return if json[:children].blank?
    json[:children].each {|item| @set.add(item[:datatype][:label])}
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