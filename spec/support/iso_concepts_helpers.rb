module IsoConceptsHelpers

  def map_ancestors(results)
    results.map{|x| {identifier: x[:identifier], scope: x[:scope].to_s, uri: x[:uri].to_s, type: x[:type].to_s}}
  end
      
end