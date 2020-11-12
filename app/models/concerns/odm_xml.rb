class OdmXml

  C_CLASS_NAME = self.name

  extend ActiveModel::Naming

  attr_reader :errors
  attr_reader :filename
  attr_reader :doc
  
  # Initialize. Initialize the class
  #
  # @param [String] filename the ODM filename, the full path
  # @return [TermOdm] class potentially containing errors
  def initialize(filename)
    @errors = ActiveModel::Errors.new(self)
    @filename = filename
    xml = PublicFile.read(filename)
    @doc = Nokogiri::XML(xml)
    @doc.remove_namespaces!
  rescue => e
    exception(C_CLASS_NAME, __method__.to_s, e, "Exception raised opening ODM XML file, filename=#{@filename}.")
  end

  # Clean Identifier
  #
  # @param [String] identifier the identifier to be cleaned
  # @return [Stirng] the cleaned identifier, upper case, no spaces, alpha numeric
  def self.clean_identifier(identifier)
    identifier.gsub(/[^A-Z0-9a-z]/i, '').upcase.strip
  end

  # Exception. Log an exception
  #
  # @param [String] klass_name the class name
  # @param [String] method_name the method name
  # @param [Exception] e the exception
  # @param [String] msg useful error message
  # @return [Void] no return
  def exception(klass_name, method_name, e, msg)
    ConsoleLogger::info(klass_name, method_name, "#{msg}\n#{e}\n#{e.backtrace.join("\n")}")
    @errors.add(:base, "#{msg} #{e}")
  end

  # Error. Log an error
  #
  # @param [String] klass_name the class name
  # @param [String] method_name the method name
  # @param [String] msg useful error message
  # @return [Void] no return
  def error(klass_name, method_name, msg)
    ConsoleLogger::info(klass_name, method_name, "#{msg}")
    @errors.add(:base, "#{msg}")
  end

end

    