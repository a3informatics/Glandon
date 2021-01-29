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

    def to_ttl!
      uri = item.has_identifier.has_scope.uri
      item.has_identifier.has_scope = uri
      uri = item.has_state.by_authority.uri
      item.has_state.by_authority = uri
      item.to_ttl
    end

  end

end