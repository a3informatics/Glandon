require "active_support/core_ext/class"

module Fuseki
  
  module Resource

    def configure(opts = {})
      name = :rdf_type
      uri = Uri.new(uri: opts[:rdf_type])
      setup(name, uri)
    end

    def object_property(name, opts = {})
      setup(name, [])
    end

    def data_property(name, opts = {})
      setup(name, "")
    end

    def setup(name, initial)
      self.send(:attr_accessor, "#{name}")
      #self.class.class_variable_get(:@@properties)[name] = initial
    end
      
  end

end