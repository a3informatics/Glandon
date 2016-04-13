module Cache

    @@property_attributes = nil
    @@link_attributes = nil

    def self.schema_attributes_set?
        return @@property_attributes != nil && @@link_attributes != nil
    end

    def self.get_schema_property_attributes
        return @@property_attributes
    end

    def self.get_schema_link_attributes
        return @@link_attributes
    end

    def self.set_schema_property_attributes(attributes)
        @@property_attributes = attributes
    end

    def self.set_schema_link_attributes(attributes)
        @@link_attributes = attributes
    end

end