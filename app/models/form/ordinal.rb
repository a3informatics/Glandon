class Form
  
  module Ordinal
    
    def reset_ordinals(parent)
      string_uris = ""
      uris_ordered(parent).each_with_index do |s, index|
        string_uris += "#{s.to_ref} bf:ordinal #{index+1} . "
      end
      query_string = %Q{
        DELETE 
        { ?s bf:ordinal ?x . }
        INSERT
        { #{string_uris} }
        WHERE 
        { ?s bf:ordinal ?x . }
      }
      results = Sparql::Update.new.sparql_update(query_string, "", [:bf])
    end

    def uris_ordered(parent)
      query_string = %Q{
        SELECT ?s WHERE {
          #{parent.uri.to_ref} bf:hasItem|bf:hasGroup|bf:hasSubGroup|bf:hasCodedValue ?s. ?s bf:ordinal ?ordinal .
        } ORDER BY ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:s)
    end

    # Move up. Move a child node up
    #
    # @param [String] parent_id the parent's node id
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_up(parent_id)
      parent = IsoConceptV2.find(Uri.new(id:parent_id))#Find parent
      parent = parent.children_ordered(self) #Order items
      index_item = parent.each_index.select{|i| parent[i].uri == self.uri }.first
      unless index_item == 0
        second_node = parent[index_item -1] 
        transaction = transaction_begin
        self.ordinal, second_node.ordinal = second_node.ordinal, self.ordinal #Swap ordinals
        second_node.save
        self.save
        transaction_execute
      else
        self.errors.add(:base, "Attempting to move up the first node")
      end
      self
    end

    # Move Down. Move a child node down
    #
    # @param [String] parent_id the parent's node id
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_down(parent_id)
      parent = IsoConceptV2.find(Uri.new(id:parent_id))#Find parent
      parent = parent.children_ordered(self) #Order items
      index_item = parent.each_index.select{|i| parent[i].uri == self.uri }.first
      unless index_item == parent.length-1
        second_node = parent[index_item +1] 
        transaction = transaction_begin
        self.ordinal, second_node.ordinal = second_node.ordinal, self.ordinal #Swap ordinals
        second_node.save
        self.save
        transaction_execute
      else
        self.errors.add(:base, "Attempting to move down the last node")
      end
      self
    end

  end

end