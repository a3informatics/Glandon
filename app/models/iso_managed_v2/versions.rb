# ISO Managed V2. Handling of versions
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class IsoManagedV2

  module Versions

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

    def previous_version?
      !previous_versions.nil?
    end

    def previous_version
      single_minimum("SELECT ?s WHERE { #{self.uri.to_ref} isoT:previousVersion ?s}")
    end

    def next_version?
      !next_versions.nil?
    end

    def next_version
      single_minimum("SELECT ?s WHERE { #{self.uri.to_ref} ^isoT:previousVersion ?s}")
    end

    def earliest_version
      single_minimum("SELECT ?s WHERE { #{self.uri.to_ref} isoT:previousVersion* ?s}")
    end

    def latest_version
      single_minimum("SELECT ?s WHERE { #{self.uri.to_ref} ^isoT:previousVersion* ?s}")
    end

  private

    def single_minimum(query)
      uri = self.class.find_single(query)
      return nil if uri.nil?
      self.class.find_minimum(self.class.find_single(query))
    end

  end

end