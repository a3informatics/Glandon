# Tabular Standard Collection. Base class for handling collections wihtin tabular standards
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class TabularStandard::Collection
  
  # Constants
  C_CLASS_NAME = self.name

  # Initialize
  #
  # @param [Hash] args argument hash
  # @option [Class] :klass the klass for the collection
  # @return [Void] no return
  def initialize(args)
    check_args(args)
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
  
  # To SPARQL
  #
  # @param [UriV3] parent_uri the uri for the parent subject
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [Void] no return
  def to_sparql(parent_uri, sparql)
    @set.each {|k, v| v.to_sparql_v2(parent_uri, sparql)}
  end

  # Test only
  #
  if Rails.env.test?
    def set
      @set
    end
  end

private

  def check_args(args)
    return if args[:klass].present?
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Missing arguments detected.")
  end

end