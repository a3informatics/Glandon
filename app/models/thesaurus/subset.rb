# Thesaurus Subset
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::Subset < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Subset"

  object_property :members, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  def initialize
      @head = nil
  end

  def add(id_cli)
    if @head.nil? #List empty
      append(id_cli)
    else
      last_item = find_tail
      last_item.next = append(id_cli)
  end

  def remove(id_cli)
    #Check list empty?
    #Check if item exists in subset -> if b.nil?
    a = find_before(id_cli)
    b = find(id_cli)

    if a.nil? #Remove the first item
      a.next= b.next
      b.delete(id_cli)
    else
      this.members=b.next
      b.delete(id_cli)
    end
  end

  def move_after(id_cli, id_cli_after = nil)

    if id_cli_after.nil? #Moving to the first position
      append_first(id_cli)
    else
      delete(id_cli)
      append_after(id_cli, id_cli_after)
    end
  end

# def subseted?
#   !subseted_by.nil?
# end

# def subseted_by
# end

# def subset_of
# end

private

  def append(value) #append to the end of the list
    if @head
      find_tail.next = SubsetMember.new(value)
    else
      @head = SubsetMember.new(value)
    end
  end

  def find_tail
      node = @head
      return node if !node.next
      return node if !node.next while (node = node.next)
  end
    
  def append_after(target, value)
      node           = find(target)
      return unless node
      old_next       = node.next
      node.next      = SubsetMember.new(value)
      node.next.next = old_next
  end

  def append_first (value)
      first_item = @head
      node = SubsetMember.new(value)
      node.next = first_item
  end
    
  def find(value)
      node = @head
      return false if !node.next
      return node  if node.value == value
      while (node = node.next)
        return node if node.value == value
      end
  end

  def delete(value)
      if @head.value == value
        @head = @head.next
        return
      end
      node      = find_before(value)
      node.next = node.next.next
  end
    
  def find_before(value)
      node = @head
      return false if !node.next
      return node  if node.next.value == value
      while (node = node.next)
        return node if node.next && node.next.value == value
      end
  end

end

end