class Tabular::Collection
  
  # Constants
  C_CLASS_NAME = self.name

  # Initialize
  #
  # @param [Hash] args argument hash
  # @option [Class] :klass the klass for the collection
  # @return [Void] no return
  def initialize(args)
    @set = {}
    @klass = args[:klass]
  end

  # Add. Will add the configured class and set the label if the label does not exist
  #  in the collection
  #
  # @param [Stirng] label the label to be added
  # @return [Object] the object. Either the exising item or the new one.
  def add(label)
    return @set[label] if @set.has_key?(label)
    object = @klass.new
    object.label = label
    @set[label] = object
    return object
  end

  # Match
  #
  # @param [Stirng] label the label to be matched
  # @return [Object] the object matching the label or nil.
  def match(label)
    return @set[label] if @set.has_key?(label)
    return nil
  end
  
  # Test only
  #
  if Rails.env.test?
    def set
      @set
    end
  end

end