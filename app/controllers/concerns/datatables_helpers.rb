# Datatables Helpers
#
# @author Dave Iberson-Hurst
# @since 3.2.0
module DatatablesHelpers

  # Format Editor Errors. Format Active Record errors for datatables editor format
  #
  # @param [Errors] errors the errors
  # @return [Array] array of hashes containing name value pairs.
  def format_editor_errors(errors)
    results = []
    errors.each {|name, msg| results << {name: name, status: msg}}
    results
  end

end
