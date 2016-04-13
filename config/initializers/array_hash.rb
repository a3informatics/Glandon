class Array
  
  def id_hash
    hash = Hash.new
    self.each{|x| hash[x.id] = x}
    return hash
  end

end