# SPARQL File. Handles file upload
#
# @author Dave Iberson-Hurst
# @since 2.40.0
module Sparql

  class File

    include Sparql::CRUD

    # Execute upload
    def upload(file)
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

    