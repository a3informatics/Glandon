module FusekiBaseHelpers
  
  def self.clear
    Fuseki::Base.instance_variable_set(:@schema, nil)
    Fuseki::Base.class_variable_set(:@@subjects, nil)
  end

  def self.read_schema
    Fuseki::Base.set_schema
  end

end