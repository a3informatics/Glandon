# ISO Concept V2 Code Value Set Tmc. Class for handling a set of code value TMc references
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class IsoConceptV2

  class CodedValueSetTmc

    def initialize(collection, parent)
      @parent = parent
      @items = []
      @map = Hash.new {|h,k| h[k] = []}
      return if collection.empty?
      return if expanded?(collection)
      expand(collection)
    end

    def update(params)
      delete_items(item_map, params[:transaction])
      @items = []
      params[:ct_reference].each_with_index {|x,i| add(x, i+1, params[:transaction])}
      update_items(params[:transaction])
    end

    def add(params, ordinal, tx=nil)
      ref = OperationalReferenceV3::TmcReference.new(reference: Fuseki::Base.as_uri(params), optional: true, ordinal: ordinal, transaction: tx)
      ref.uri = ref.create_uri(@parent.uri)
      @items << ref
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
        @map[item[:id]].delete
      end
    end

    def expanded?(collection)
      return false unless collection.first.is_a?(OperationalReferenceV3::TmcReference)
      @items = collection
      collection.each {|x| @map[x.reference.to_id] = x}
      true
    end
        
    def item_map
      @items.map{|x| {id: x.reference.to_id }}
    end

    def uri_or_id_map(uris_or_ids)
      uris_or_ids.map{|x| as_uri(x).to_id}
    end

    def expand(collection)
      collection.each do |uri_or_id|
        uri = Fuseki::Base.as_uri(uri_or_id)
        item = OperationalReferenceV3::TmcReference.find(uri)
        @items << item
        @map[item.reference.to_id] = item
      end
    end

  end

end