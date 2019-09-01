# Instruction. A single change instruction
#
# @author Dave Iberson-Hurst
# @since 2.22.2
class Import::ChangeInstructions::Instruction

  #include ActiveModel::Naming
  #include ActiveModel::Conversion
  #include ActiveModel::Validations
      
  attr_accessor :previous_parent
  attr_accessor :previous_children
  attr_accessor :current_parent
  attr_accessor :current_children

  # Initialize
  #
  # @return [Void] no return
  def initialize
    @previous_parent = []
    @previous_children = []
    @current_parent = []
    @current_children = []
  end

  # Previous. The previous results. A set of parent and optional child references as an array
  #
  # @return [Array] array of parent child references
  def previous
    results = []
    @previous_parent.each do |p|
      if @previous_children.empty?
        results << [p]
      else
        @previous_children.each do |c|
          results << [p, c]
        end
      end
    end
    results
  end

  # Current. The current results. A set of parent and optional child references as an array
  #
  # @return [Array] array of parent child references
  def current
    results = []
    @current_parent.each do |p|
      if @current_children.empty?
        results << [p]
      else
        @current_children.each do |c|
          results << [p, c]
        end
      end
    end
    results
  end

  # Valid? Data is valid. Certain combinations are not.
  #
  # @return [Boolean] true if valid, false otherwise
  def valid?
    return false if @previous_children.count == 0 && @current_children.count > 0 
    return false if @previous_children.count > 0 && @current_children.count == 0 
    return false if @previous_children.count > 1 && @current_children.count > 1
    return false if @previous_parent.count > 1 && @current_parent.count > 1
    return true
  end

end