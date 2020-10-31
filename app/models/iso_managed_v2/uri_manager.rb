# ISO Managed V2 Uri Manager. Class to handle uris
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoManagedV2

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

    # To Ids 
    #
    # @result [Hash] Hash of ids with the old_uris converted to ids as keys and the new_uris converted to id as values
    def to_ids
      ids = {}
      @uris.each{|key, value| ids[key.to_id] = value.to_id}
      ids
    end

  end

end