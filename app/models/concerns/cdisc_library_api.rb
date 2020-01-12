# CDISC Library API. Handles the CDISC API
#
# @author Dave Iberson-Hurst
# @since 2.27.0
class CDISCLibraryAPI

  C_HREF_SEPARATOR = "/"
  C_CT_PACKAGES_URL = "mdr/ct/packages"

  # CT Packges. Get a list of the packages from the library. Will transform the result
  #   into something slightly more useful.
  #
  # @return [Hash] hash keyed by date (as a string) each containg an array of sources.
  def ct_packages
    check_enabled
    result = Hash.new {|h,k| h[k] = [] }
    response = send_request("#{base_href}#{C_CT_PACKAGES_URL}")
    response[:_links][:packages].each do |source|
      date = source[:title].scan(/(\d\d\d\d-\d\d-\d\d)/).last.first
      package = source[:title].scan(/( \d+ )/).last.first.strip.to_i
      result[date] << {title: source[:title], date: date, package: package, href: source[:href]}
    end
    result = result.sort.to_h
  end

  def ct_package(required_date)
    check_enabled
    list = ct_packages
    Errors.application_error(self.class.name, __method__.to_s, "No CT release matching requested date '#{date}'.") if !list.key?(date)
    hrefs_for_date(required_date)
  end

  # Enabled? Is the API enabled?
  #
  # @raise [Errors::ApplicationLogicError] raised if soemthign went wrong determining if the interface is enabled.
  # @return [Boolean] true if enabled, false otherwise
  def enabled?
    EnvironmentVariable.read("cdisc_library_api_enabled").to_bool
  rescue => e
    application_error(self.class.name, __method__.to_s, "Error detected determining if CDISC Library API enabled.")
  end

private
  
  def check_enabled
    Errors.application_error(self.class.name, __method__.to_s, "The CDISC Library API is not enabled.") unless enabled?
  end

  def hrefs_for_date(list, required_date)
    hrefs = {}
    dates = list.keys.reverse
    sources.each do |source|
      dates.each do |date|
        next if title_to_key(list[date][:title]).upcase != source.upcase
        hrefs[source] << list[date][:href]
        break
      end
    end
    return hrefs if href.keys == sources
    missing = sources - href.keys
    application_error(self.class.name, __method__.to_s, "Missing sources when looking for hrefs for release '#{requireddate}'.")
  end

  def sources
    api_configuration[:ct][:sources].keys
  end

  def title_to_key(title)
    title.split(" ").first
  end

  # Get the API base href
  def base_href
    href = api_configuration[:base_href]
    href += C_HREF_SEPARATOR unless href.end_with?(C_HREF_SEPARATOR)
    href
  end

  # Send a request to the API and get a response.
  def send_request(href)
    headers = {"Accept" => "application/json"}
    response = Rest.send_request(href, :get, ENV["cdisc_library_api_username"], 
      ENV["cdisc_library_api_password"], "", headers)
    JSON.parse(response.body).deep_symbolize_keys
  end

  # Get the API configuration
  def api_configuration
    Rails.configuration.imports[:processing][:cdisc_library_api]
  end

end    