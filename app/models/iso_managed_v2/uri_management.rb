# ISO Managed Uri Management. Methods to handle URI management
#
# @author Dave Iberson-Hurst
# @since 3.3.0
class IsoManagedV2
  
  module UriManagement

    # Modified URIs As Ids
    #
    # @return [Array] the modified URIs as an array of hashes
    def modified_uris_as_ids
      @uri_managed.to_ids
    end
    
    # Add Modified URI
    #
    # @param [Uri] old_uri the old uri
    # @param [Uri] new_uri the new uri
    # @return [Void] no return
    def add_modified_uri(old_uri, new_uri)
      @uri_managed.add(old_uri, new_uri)
    end

    # ---------
    # Test Only  
    # ---------
    
    if Rails.env.test?

      def modified_uris
        @uri_managed.to_uris
      end

      def the_uri_manager
        @uri_managed
      end

    end

  end

end