# ISO Managed V2. Handling of export
#
# @author Dave Iberson-Hurst
# @since 3.8.0
class IsoManagedV2

  module Export

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # ----------------
    # Instance Methods
    # ----------------

    # To TTL. Destructive metthod to output item as TTL
    #
    # @return [Path] the path to the resulting file
    def to_ttl!
      uri = self.has_identifier.has_scope.uri
      # @todo replace with export paths
      self.has_identifier.has_scope = uri
      uri = self.has_state.by_authority.uri
      self.has_state.by_authority = uri
      self.to_ttl
    end

  end

end