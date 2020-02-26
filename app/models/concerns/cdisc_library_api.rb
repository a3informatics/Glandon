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

  # CT Packges By Date. Return the sources for a specified date. The date must exist.
  #
  # @raise [Errors::ApplicationLogicError] raised if date not found.
  # @return [Hash] hash keyed by date (as a string) each containg an array of sources.
  def ct_packages_by_date(required_date)
    check_enabled
    list = ct_packages
    Errors.application_error(self.class.name, __method__.to_s, "No CT release found matching requested date '#{required_date}'.") if !list.key?(required_date)
    hrefs_for_date(list, required_date)
  end

  # CT Packge. Return a single CT package.
  #
  # @param [String] href the package href
  # @return [Hash] hash containing the resulting data
  def ct_package(href)
    check_enabled
    send_request(full_href(href))
  end

  # Enabled? Is the API enabled?
  #
  # @raise [Errors::ApplicationLogicError] raised if something went wrong determining if the interface is enabled.
  # @return [Boolean] true if enabled, false otherwise
  def enabled?
    EnvironmentVariable.read("cdisc_library_api_enabled").to_bool
  rescue => e
    Errors.application_error(self.class.name, __method__.to_s, "Error detected determining if CDISC Library API enabled.")
  end

  # CT Tags. Return the tag associated with the CT pacakge
  #
  # @param [String] title the title for the stream
  # @return [Array] Array of tags associated with the stream
  def ct_tags(title)
    product = product_from_title(title)
    entry = ct_products.select{|k,v| v[:label].upcase == product.upcase}
    return [] if entry.blank?
    entry.values.first[:tags]
  end

  # ---------
  # Test Only
  # ---------

  if Rails.env.test?
    
    def request(href)
      send_request(full_href(href))
    end

  end

private

  # Check interface is enabled, raise error if not.
  def check_enabled
    Errors.application_error(self.class.name, __method__.to_s, "The CDISC Library API is not enabled.") unless enabled?
  end

  # Find the set of hrefs for the specified date.
  def hrefs_for_date(list, required_date)
    hrefs = {}
    dates = list.keys.reverse
    products = ct_products_by_date(required_date)
    products.each do |product, details|
      found = false
      dates.each do |date|
        next if date.to_date > required_date.to_date
        list[date].each do |source|
          next if product_from_title(source[:title]).upcase != details[:label].upcase
          hrefs[product] = source[:href]
          found = true
          break
        end
        break if found
      end
    end
    return hrefs if hrefs.keys == products.keys
    missing = products.keys - hrefs.keys
    Errors.application_error(self.class.name, __method__.to_s, "Missing sources '#{missing}' when looking for hrefs for release '#{required_date}'.")
  end

  # Find the ct products from the config data filtered by date
  def ct_products_by_date(required_date)
    ct_products.select{|k,v| required_date.to_date.between?(v[:from].to_date, v[:to].to_date) }
  end

  # Find the ct products from the config data
  def ct_products
    api_configuration[:ct][:products]
  end

  # Gets a product from a source title
  def product_from_title(title)
    title.split(" ").first
  end

  # Get the API base href
  def base_href
    href = api_configuration[:base_href]
    href += C_HREF_SEPARATOR unless href.end_with?(C_HREF_SEPARATOR)
    href
  end

  # Build full href froma partial
  def full_href(href)
    href.slice!(0) if href[0,1] == C_HREF_SEPARATOR
    "#{base_href}#{href}"
  end

  # Send a request to the API and get a response.
  def send_request(href)
    headers = {"Accept" => "application/json"}
    response = Rest.send_request(href, :get, ENV["cdisc_library_api_username"], 
      ENV["cdisc_library_api_password"], "", headers)
    return JSON.parse(response.body).deep_symbolize_keys if response.success?
    process_error(response, href)
  end

  # Handle the error
  def process_error(response, href)
    if response.timed_out?
      msg = "Request to CDISC API #{href} failed, timed out."
    elsif response.code == 0
      msg = "Request to CDISC API #{href} failed, 0 error: #{response.return_message}."
    else
      msg = "Request to CDISC API #{href} failed, HTTP error: #{response.code}."
    end
    ConsoleLogger.info(self.class.name, __method__.to_s, msg)
    raise Errors::NotFoundError.new(msg)
  end

  # Get the API configuration
  def api_configuration
    Rails.configuration.imports[:processing][:cdisc_library_api]
  end

end    