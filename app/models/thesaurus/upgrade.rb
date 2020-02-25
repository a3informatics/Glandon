
class Thesaurus

  module Upgrade

    def upgrade(th)
      init(th, self)
      execute
    end

  private  

    def init(th, tc)
      @th = th
      @tc = tc
      @type = set_type
      @new_tc = set_new      
    end

    def execute
      return upgrade_extension(@new_tc) if @type == :extension
      return upgrade_subset(@new_tc) if @type == :sponsor_subset || :ref_subset
      Errors.application_error(self.class.name, __method__.to_s, "Only Subsets or Extensions can be upgraded.")
    end

    def set_type
      return :extensible if @tc.is_extensible?
      return :sponsor_subset @tc.is_subset? and @tc.subsets.owner == owner
      :ref_subset
    end

    def set_new
      th = set_target_th
      results = th.find_identifier(@tc.identifier)
      Errors.application_error(self.class.name, __method__.to_s, "Only Subsets or Extensions can be upgraded.") if results.empty?
      Thesaurus::ManagedConcept(results.first[:uri])
    end

    def set_target_th
      if @type == :sponsor_subset
        @target_th = @th
      else
        @th.reference_objects
        @target_th = @th.reference.reference
      end
    end

    def proceed?
      return true if @type != :ref_subset
      # Check upgraded.
    end

  end

end