# Environment Variable. interface to read an environment variable. Allows for Rspec testing to be 
#   made a little easier.
#
# @author Dave Iberson-Hurst
# @since 2.27.0
module EnvironmentVariable

  # Read. Reads an environment variable. Allows the read to be intercepted in Rspec.
  #
  # @param [String|Symbol] name the variable name
  # @raise [ApplicationLogicError] raised if any errors detected (usually name not found)
  # @return [String] the value of the required environment variable
  def self.read(name)
    value = ENV["#{name}"]
    Errors.application_error("EnvironmentVariable", "Read", "Error reading environment variable '#{name}'.") if value.nil?
    value
  end

end