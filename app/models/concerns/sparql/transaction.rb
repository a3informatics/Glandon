# SPARQL Transaction. Builds several updates into a transaction.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Transaction

    include Sparql::CRUD

    C_CLASS_NAME = self.name

    def initialize()  
      @parts = []
    end

    # Transaction Start. Start a transaction
    #
    # @return [Void] no return
    def add(sparql)
      @parts << sparql
    end

    # Execute. Excute the transaction
    #
    # @return [Void] no return
    def execute
      response = send_update(@parts.join(";\n"))
      if !response.success?
        base = "Failed to execute a SPARQL transaction."
        message = "#{base}\nSPARQL: #{sparql}"
        ConsoleLogger.info(C_CLASS_NAME, __method__.to_s, message)
        raise Errors::UpdateError.new(base)
      end
    end

  end

end

    