# Form ordinal. Mixin to handle ordinal actions
#
# @author Clarisa Romero
# @since 3.2.0
class Form
  
  module Ordinal
    
    # Reset Ordinals. Reset the ordinals within the enclosing parent
    #
    # @return [Boolean] true if reordered, false otherwise.
    def reset_ordinals
      local_uris = uris_by_ordinal
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
      results = Sparql::Update.new.sparql_update(query_string, "", [:bf])
      true
    end

    # Move up. Move a child node up
    #
    # @param [Object] child the child object
    # @return [Object] the object updated. May contain errors if unsuccesful.
    def move_up(child)
      move(child, :up, "Attempting to move up past the first node")
    end

    # Move Down. Move a child node down
    #
    # @param [String] parent_id the parent's node id
    # @return [Boolean] true if move succesful
    def move_down(parent_id)
      move(parent_id, :down, "Attempting to move down past the last node")
    end

  private

    # Return URIs of the children objects ordered by ordinal, make sure common group marked and placed first
    def uris_by_ordinal
      query_string = %Q{
        SELECT ?s WHERE {
          {
            #{self.uri.to_ref} bf:hasCommon ?s . 
            BIND ("A" as ?type)
          } 
          UNION 
          {
            #{self.uri.to_ref} bf:hasItem|bf:hasGroup|bf:hasSubGroup|bf:hasCodedValue ?s .  
            BIND ("B" as ?type)
          }
          ?s bf:ordinal ?ordinal .
        } ORDER BY ?type ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      query_results.by_object(:s)
    end

    # Move the item up or down.
    def move(child, dir, error_msg)
      children = self.children_ordered # Order items
      index_item = children.each_index.select{|i| children[i].uri == child.uri}.first
      end_stop = dir == :up ? 0 : children.length-1
      unless index_item == end_stop
        increment = dir == :up ? -1 : 1
        second_node = children[index_item + increment] 
        transaction = transaction_begin
        temp = child.ordinal
        child.ordinal, second_node.ordinal = second_node.ordinal, temp
        second_node.save
        child.save
        transaction_execute
        true
      else
        self.errors.add(:base, error_msg)
        false
      end
    end

  end

end