class TabularStandard::Compliance < TabularStandard::Collection
  
  # Constants
  C_CLASS_NAME = self.name

  # Initialize
  #
  # @return [Void] no return
  def initialize
    super(klass: SdtmModelCompliance)
  end

end