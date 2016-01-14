module FormNode

    @@key = 1

    def self.new(id, ns, nodeType, name, label, identifier, note, ordinal, index, enabled)
        child = Hash.new
        child[:id] = id
        child[:namespace] = ns
        child[:type] = nodeType
        child[:name] = name
        child[:label] = label
        child[:identifier] = identifier
        child[:note] = note
        child[:ordinal] = ordinal
        child[:index] = index
        child[:enabled] = enabled
        child[:key] = @@key
        child[:children] = Array.new
        child[:save] = Array.new
        @@key += 1
        return child
    end
  
end

    