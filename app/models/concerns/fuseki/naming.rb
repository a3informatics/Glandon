module Fuseki
  
  module Naming
  
    def to_rails(name)
      "@#{name.underscore}".to_sym # to underscore convention with preceeding '@' to symbol
    end

    def to_schema(name)
      "#{name}"[1..-1].camelcase(:lower) # From symbol, remove the '@' and then to camelcase with lower first char
    end

  end

end