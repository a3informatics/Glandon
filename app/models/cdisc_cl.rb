# CDISC Code List
#
# @author Dave Iberson-Hurst
# @since 0.0.1
class CdiscCl < Thesaurus::ManagedConcept

  def children
    return self.narrower
  end
  
  def self.owner
    CdiscTerm.owner
  end

end
