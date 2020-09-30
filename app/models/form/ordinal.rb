# Form ordinal. Mixin to handle ordinal actions
#
# @author Clarisa Romero
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
      string_uris = {delete: "", insert: "", where: ""}
      local_uris.each_with_index do |s, index|
        string_uris[:delete] += "#{s.to_ref} bf:ordinal ?x#{index} . "
        string_uris[:insert] += "#{s.to_ref} bf:ordinal #{index+1} . "
        string_uris[:where] += "#{s.to_ref} bf:ordinal ?x#{index} . "
      end
      query_string = %Q{
        DELETE 
          { #{string_uris[:delete]} }
        INSERT
          { #{string_uris[:insert]} }
        WHERE 
          { #{string_uris[:where]} }
      }
puts "Q: #{query_string}"
      results = Sparql::Update.new.sparql_update(query_string, "", [:bf])
      true
    end

    # Move up. Move a child node up
    #
    # @param [String] parent_id the if of the parent node
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_up(parent_id)
      move(parent_id, :up, "Attempting to move up past the first node")
    end

    # Move Down. Move a child node down
    #
    # @param [String] parent_id the parent's node id
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_down(parent_id)
      move(parent_id, :down, "Attempting to move down past the last node")
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