# ISO Concept V2 Code Value Set. Class for handling a set of code value references
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class IsoConceptV2

  class CodedValueSet

    def initialize(collection, parent)
      @parent = parent
      @items = []
      @map = Hash.new {|h,k| h[k] = []}
      return if collection.empty?
      return if expanded?(collection)
      collection.each do |uri_or_id|
        uri = Fuseki::Base.as_uri(uri_or_id)
        item = OperationalReferenceV3::TucReference.find(uri)
        @items << item
        @map[item.reference.to_id] = item
      end
    end

    def update(params)
      current = item_map
      updated = params[:has_coded_value]
      delete_set = current - updated
      add_set = updated - current
      @items.reject!{|x| delete_set.include?(x.id)}
      add_set.each {|x| add(x, params[:transaction])}
      sort!(updated)
      delete_items(delete_set, params[:transaction])
      update_items(params[:transaction])
    end

    def add(params, tx=nil)
      ref = OperationalReferenceV3::TucReference.new(context: Fuseki::Base.as_uri(params[:context_id]), reference: Fuseki::Base.as_uri(params[:id]), optional: true, ordinal: @items.count+1, transaction: tx)
      ref.uri = ref.create_uri(@parent.uri)
      @items << ref
    end

    def sort!(ids)
      @items = @items.index_by{|z| z.reference.to_id}.values_at(*ids.map{|x| x[:id]}) 
      @items.each_with_index{|x,i| x.ordinal = i+1}
    end

    def items
      @items
    end

  private

    def update_items(tx)
      @items.each do |x|
        #x.set_transaction(tx)
        x.save
      end
    end

    def delete_items(items, tx)
      items.each do |item|
        #item.set_transaction(tx)
        item.delete(@map[item[:id]])
      end
    end

    def expanded?(collection)
      return false unless collection.first.is_a?(OperationalReferenceV3::TucReference)
      @items = collection
      collection.each {|x| @map[x.reference.to_id] = x}
      true
    end
        
    def item_map
      @items.map{|x| {id: x.reference.to_id, context_id: x.context.to_id}}
    end

    def uri_or_id_map(uris_or_ids)
      uris_or_ids.map{|x| as_uri(x).to_id}
    end

  end

end