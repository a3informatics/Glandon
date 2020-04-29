# Imports Sponsor Term Format Two Terminology Controller.
#
# @author Dave Iberson-Hurst
# @since 2.39.0
class Imports::SponsorTermFormatTwoController < Imports::BaseController

  def create
    model = Import::SponsorTermFormatTwo.params_valid?(the_params)
    if model.errors.empty?
      super
    else
      flash[:error] = model.errors.full_messages.to_sentence
      redirect_to request.referrer
    end
  end

private

  def the_params
    super
  end

end
