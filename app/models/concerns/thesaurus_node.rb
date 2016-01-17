module ThesaurusNode

    def self.new(node)
        child = Hash.new
        child[:name] = node.identifier + ' [' + node.notation + ']'
        child[:identifier] = node.identifier
        child[:label] = node.label
        child[:id] = node.id
        child[:namespace] = node.namespace
        child[:notation] = node.notation
        child[:definition] = node.definition
        child[:synonym] = node.synonym
        child[:preferredTerm] = node.preferredTerm
        child[:expand] = false
        child[:endIndex] = 0
        child[:startIndex] = 0
        child[:expansion] = Array.new  
        return child
    end

end

    