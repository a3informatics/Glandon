# CDISC Library API Reader. Reads a single url content
#
# @author Dave Iberson-Hurst
# @since 2.27.0
# @attr_reader [ActiveModel::Errors] the Active Model errors class
# @attr_reader [CDISCLibraryAPIReader::Engine] the reader engine
class CDISCLibraryAPIReader

  extend ActiveModel::Naming

  attr_reader :errors
  attr_reader :engine

  # Initialize. Opens the workbook ready for processing.
  #
  # @param [String] href the href to be read 
  # @return [Void] no return value
  def initialize(href)
    @errors = ActiveModel::Errors.new(self)
    @href = href
    @engine = CDISCLibraryAPIReader::Engine.new(self)
  end

  # Execute. Execure the import
  #
  # @params [Hash] params ignored. Set to preserve commonality of interface
  # @return [Void] no return  
  def execute(params)
    @engine.process(@href)    
  end

end    