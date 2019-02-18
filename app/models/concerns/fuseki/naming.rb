module Fuseki
  
  module Naming
  
    def to_rails(name)
      "@#{name.underscore}".to_sym # to underscore convention with preceeding '@' to symbol
    end

    def to_schema(name)
      "#{name}"[1..-1].camelcase(:lower) # From symbol, remove the '@' and then to camelcase with lower first char
    end

    def from_rails(name)
      "#{name}"[1..-1].to_sym # From symbol, remove the '@'
    end

    class Variable

      def initialize(name)
        @name = "#{name}".first == "@" ? "#{name}"[1..-1] : "#{name}"
      end

      def for_instance
        "@#{@name}".to_sym # @<name>
      end

      def for_schema
        "#{@name}".camelcase(:lower) # Camelcase with lower first char
      end

      def for_rails
        "#{@name}".to_sym # Symbol, not @
      end

    end

  end

end