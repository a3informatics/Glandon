class SdtmSponsorDomainPolicy < ApplicationPolicy
  # Initialize. Add in the extra methods
  #
  # @param [User] user the user
  # @param [Object] record the record being accessed
  # @return [void] no return
  def initialize(user, record)
    super
    create_methods(self.class.name)
  end
end