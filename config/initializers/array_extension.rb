class Array

  # Think this can be deprecated
  def id_hash
    hash = Hash.new
    self.each{|x| hash[x.id] = x}
    return hash
  end

  # Find All Duplicates
  #
  # @return [Array] array of duplicate values
  def find_all_duplicates
    self.group_by{|e| e}.select {|k, v| v.size > 1}.map(&:first)
  end

end