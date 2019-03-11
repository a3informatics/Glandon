# Fuseki Persistence Naming. Handles the different name forms between rails, schema and class properties
#
# rails attribute: fred_smith
# schema predicate: fredSmith
# class instance: :@fred_smith
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Persistence
  
    class Naming

      # Initialize
      #
      # @param name [String] the name
      # @return [Void] no return
      def initialize(name)
        if "#{name}".first == "@"
          @name = "#{name}"[1..-1] 
        else
          @name = "#{name}".underscore
        end
      end

      # As Instance. The class instance form
      #
      # @return [Symbol] the instance symbol form
      def as_instance
        "@#{@name}".to_sym # @<name> as a symbol
      end

      # As Schema. The schema form
      #
      # @return [String] the schema form
      def as_schema
        "#{@name}".camelcase(:lower) # Camelcase with lower first char
      end

      # As Symbol. The rails symbol form
      #
      # @return [Symbol] the symbol form
      def as_symbol
        "#{@name}".to_sym # Symbol, no leading @
      end

    end

  end

end