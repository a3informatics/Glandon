# SPARQL Transaction. Builds several updates into a transaction.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Transaction

    include Sparql::CRUD

    C_CLASS_NAME = self.name

    # Initialize
    #
    # @return [Object] the new instance
    def initialize()  
      @parts = []
      @instances = []
    end

    # Add. Add to the transactions
    #
    # @return [Void] no return
    def add(sparql)
      @parts << sparql
    end

    # Register. Register the calling instance so transction can be cleaned up
    #
    # @return [Void] no return
    def register(instance)
      @instances << instance
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
      else
        @instances.each {|i| i.transaction_clear}
      end
    end

    # ---------
    # Test Only
    # ---------
    
    if Rails.env.test?

      def status
        {parts: @parts, instances: @instances}
      end

    end

  end

end

    