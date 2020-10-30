# Uri Manager. Class to handle uris
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class UriManager

  # Initialize
  #
  # @return [Hash] empty hash
  def initialize
    @uris = {}
  end


  # Add. 
  #
  # @param [Uri] old_uri the old uri 
  # @param [Uri] new_uri the new uri
  # @result [Hash] Hash of URIs with the old_uris as keys and the new_uris as values
  def add(old_uri, new_uri)
    @uris[old_uri] = new_uri
  end

  # To h. 
  #
  # @result [Hash] Hash of IDs with the old_uris converted to id as keys and the new_uris converted to id as values
  def to_h
    ids = {}
    @uris.each{|key, value| ids[key.to_id] = value.to_id}
    ids
  end

end