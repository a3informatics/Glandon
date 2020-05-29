# SPARQL File. Handles file upload
#
# @author Dave Iberson-Hurst
# @since 2.40.0
module Sparql

  class Upload

    include Sparql::CRUD

    # Send. Send (upload) a file to the DB
    #
    # @param [String] file the full path for the file to be uploaded
    # @raise [Errors::CreateError] raised if upload not a success
    # @return [Void] no return
    def send(file)
      response = send_file(file)
      if !response.success?
        base = "Failed to upload and create an item in the database."
        message = "#{base}\nFilename: #{file}"
        ConsoleLogger.info(self.class.name, __method__.to_s, message)
        raise Errors::CreateError.new(base)
      end
    end

  end

end