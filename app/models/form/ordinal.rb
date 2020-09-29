# Form ordinal. Mixin to handle ordinal actions
#
# @author Claris Romero
# @since 3.2.0
class Form
  
  module Ordinal
    
    # Reset Ordinals. Reset the ordinals within the enclosing parent
    #
    # @param [String] parent the parent object for the group being ordered
    # @return [Boolean] true if reordered, false otherwise.
    def reset_ordinals(parent)
      local_uris = uris_by_ordinal(parent)
      return false if local_uris.empty?
      string_uris = ""
      local_uris.each_with_index do |s, index|
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
      true
    end

    # Move up. Move a child node up
    #
    # @param [String] parent_id the if of the parent node
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_up(parent_id)
      move(parent_id, :up, "Attempting to move up past the first node")
      # parent = IsoConceptV2.find(Uri.new(id:parent_id))#Find parent
      # parent = parent.children_ordered(self) #Order items
      # index_item = parent.each_index.select{|i| parent[i].uri == self.uri }.first
      # unless index_item == 0
      #   second_node = parent[index_item -1] 
      #   transaction = transaction_begin
      #   self.ordinal, second_node.ordinal = second_node.ordinal, self.ordinal #Swap ordinals
      #   second_node.save
      #   self.save
      #   transaction_execute
      # else
      #   self.errors.add(:base, "Attempting to move up the first node")
      # end
      # self
    end

    # Move Down. Move a child node down
    #
    # @param [String] parent_id the parent's node id
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_down(parent_id)
      move(parent_id, :down, "Attempting to move down past the last node")
      # parent = IsoConceptV2.find(Uri.new(id:parent_id))#Find parent
      # parent = parent.children_ordered(self) #Order items
      # index_item = parent.each_index.select{|i| parent[i].uri == self.uri }.first
      # unless index_item == parent.length-1
      #   second_node = parent[index_item +1] 
      #   transaction = transaction_begin
      #   self.ordinal, second_node.ordinal = second_node.ordinal, self.ordinal #Swap ordinals
      #   second_node.save
      #   self.save
      #   transaction_execute
      # else
      #   self.errors.add(:base, "Attempting to move down the last node")
      # end
      # self
    end

  private

    # Return URIs of the children objects ordered by ordinal, make sure common group marked and placed first
    def uris_by_ordinal(parent)
      query_string = %Q{
        SELECT ?s WHERE {
          {
            #{parent.uri.to_ref} bf:hasCommon ?s . 
            BIND ("A" as ?type)
          } 
          UNION 
          {
            #{parent.uri.to_ref} bf:hasItem|bf:hasGroup|bf:hasSubGroup|bf:hasCodedValue ?s .  
            BIND ("B" as ?type)
          }
          ?s bf:ordinal ?ordinal .
        } ORDER BY ?type ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:s)
    end

    # Move the item up or down.
    def move(parent_id, dir, error_msg)
      parent = IsoConceptV2.find(Uri.new(id: parent_id))
      parent = parent.children_ordered(self) # Order items
      index_item = parent.each_index.select{|i| parent[i].uri == self.uri}.first
      end_stop = dir == :up ? 0 : parent.length-1
      unless index_item == end_stop
        increment = dir == :up ? -1 : 1
        second_node = parent[index_item + increment] 
        transaction = transaction_begin
        self.ordinal, second_node.ordinal = second_node.ordinal, self.ordinal # Swap ordinals
        second_node.save
        self.save
        transaction_execute
      else
        self.errors.add(:base, error_msg)
      end
      self
    end

  end

end