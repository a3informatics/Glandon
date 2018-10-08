# Handles the raising of errors. Will log the error and raise an exception.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Errors

  # Object Create Error. Call if issues found during object creation.
  #
  # @param [String] class_name The class name of the unit raising the error. Will be limited to a set width.
  # @param [String] method_name The name of the method raising the error. Will be limited to a set width.
  # @param [String] text The text to be logged.
  # @raise Errors::CreateError
  def self.object_create_error(class_name, method_name, object)
    message = "Failed to create #{class_name}. #{object.errors.full_messages.to_sentence}."
    ConsoleLogger.info(class_name, method_name, message)
    raise Errors::CreateError.new(message)
  end

  # Object Update Error. Call if issues found during object updates.
  #
  # @param [String] class_name The class name of the unit raising the error. Will be limited to a set width.
  # @param [String] method_name The name of the method raising the error. Will be limited to a set width.
  # @param [String] text The text to be logged.
  # @raise Errors::UpdateError
  def self.object_update_error(class_name, method_name, object)
    message = "Failed to update #{class_name}. #{object.errors.full_messages.to_sentence}."
    ConsoleLogger.info(class_name, method_name, message)
    raise Errors::UpdateError.new(message)
  end

  # Object Destroy Error. Call if issues found during object destruction.
  #
  # @param [String] class_name The class name of the unit raising the error. Will be limited to a set width.
  # @param [String] method_name The name of the method raising the error. Will be limited to a set width.
  # @param [String] text The text to be logged.
  # @raise Errors::DestroyError
  def self.object_destroy_error(class_name, method_name, e)
    message = "Failed to destroy #{class_name}. #{e.message} #{e.backtrace.join("\n")}"
    ConsoleLogger.info(class_name, method_name, message)
    raise Errors::DestroyError.new(message)
  end

  # Object Not Found Error. Call if an object is not found.
  #
  # @param [String] class_name The class name of the unit raising the error. Will be limited to a set width.
  # @param [String] method_name The name of the method raising the error. Will be limited to a set width.
  # @param [String] text The text to be logged.
  # @raise Errors::NotFoundError
  def self.object_not_found_error(class_name, method_name, params)
    message = "Failed to find object #{class_name} with #{params}"
    ConsoleLogger.info(class_name, method_name, message)
    raise Errors::NotFoundError.new(message)
  end

  # Application Error. Call when an application error occurs.
  #
  # @param [String] class_name The class name of the unit raising the error. Will be limited to a set width.
  # @param [String] method_name The name of the method raising the error. Will be limited to a set width.
  # @param [String] text The text to be logged.
  # @raise Errors::ApplicationLogicError
  def self.application_error(class_name, method_name, message)
    ConsoleLogger.info(class_name, method_name, message)
    raise Errors::ApplicationLogicError.new(message)
  end

  # ----------------------
  # Exception Declarations
  # ----------------------
  
  class DestroyError < StandardError
  end

  class UpdateError < StandardError
  end

  class CreateError < StandardError
  end

  class NotFoundError < StandardError  
  end

  class ApplicationLogicError < StandardError  
  end

end