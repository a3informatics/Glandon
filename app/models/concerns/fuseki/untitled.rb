module Fuseki
  
  module Naming
  
    def to_rails(name)
      return "@#{name.underscore}".to_sym
    end

    def to_schema(name)
      return "@#{name.underscore}".to_sym
    end

  end

end