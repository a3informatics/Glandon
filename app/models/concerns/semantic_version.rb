class SemanticVersion

  C_CLASS_NAME = "SemanticVersion"

  attr_reader :major, :minor, :patch

  # Initialize
  #
  # @param args [Hash] the argument hash
  # @return [Null] no return
  def initialize(args)
    @major = 0
    @minor = 0
    @patch = 0
    @major = args[:major] if args[:major]
    @minor = args[:minor] if args[:minor]
    @patch = args[:patch] if args[:patch]
  end
  
  # from String
  #
  # @param version [String] string representation of the semantic version (major.minor.patch)
  # @return [SemanticVersion] the resulting object
  def self.from_s(version)
    object = self.new({})
    return object if version.blank?
    parts = version.split('.')
    if parts.length == 3
      object = self.new(major: parts[0].to_i(10), minor: parts[1].to_i(10), patch: parts[2].to_i(10))
    elsif parts.length == 2
      object = self.new(major: parts[0].to_i(10), minor: parts[1].to_i(10), patch: 0)
    elsif parts.length == 1
      object = self.new(major: parts[0].to_i(10), minor: 0, patch: 0)
    end
    return object
  end

  # Increment Major
  #
  # @return [Null] no return
  def increment_major
    @major += 1
    @minor = 0
    @patch = 0
  end
  
  # Increment Minor
  #
  # @return [Null] no return
  def increment_minor
    @minor += 1
    @patch = 0
  end
  
  # >
  #
  # @return [Boolean] true if greated
  def >(other)
    return true if self.major > other.major
    return true if self.minor > other.minor
    return true if self.patch > other.patch
    return false
  end
  
  # To String
  #
  # @param type [Symbol] either :full for all three fields or :partial for majoe and minor only.
  # @return [String] The version string
  def to_s(type = :full)
    return "#{@major}.#{@minor}" if type == :partial
    return "#{@major}.#{@minor}.#{@patch}"
  end

end
