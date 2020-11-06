# Custom Property Set. A utility class holding the set of custom propeeties for a model.
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class CustomPropertySet
  
  def initialize
    @items = []
  end

  def <<(item)
    @items << item
  end

  def to_h
    @items.map {|x| x.to_h}
  end

end