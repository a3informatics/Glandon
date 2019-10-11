# Instruction. A single change instruction
#
# @author Dave Iberson-Hurst
# @since 2.22.2
class Import::ChangeInstruction::Instruction

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :previous_parent
  attr_accessor :previous_children
  attr_accessor :current_parent
  attr_accessor :current_children
  attr_accessor :description
  attr_reader :errors

  # Initialize
  #
  # @return [Void] no return
  def initialize
    @previous_parent = []
    @previous_children = []
    @current_parent = []
    @current_children = []
    @errors = ActiveModel::Errors.new(self)
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
    @errors.clear
    add_error("Previous term empty but current term is not.") if @previous_children.count == 0 && @current_children.count > 0 
    add_error("Previous term is not empty but current term is empty.") if @previous_children.count > 0 && @current_children.count == 0 
    add_error("Multiple previous and current terms.") if @previous_children.count > 1 && @current_children.count > 1
    add_error("Multiple previous and current code lists.") if @previous_parent.count > 1 && @current_parent.count > 1
    return @errors.empty?
  end

  # Owner. Same as CDISC CT Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    ::CdiscTerm.owner
  end

private

  def add_error(text)
    @errors.add(:base, text)
    false
  end
end