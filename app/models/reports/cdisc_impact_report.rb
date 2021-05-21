class Reports::CdiscImpactReport

  C_CLASS_NAME = "Reports::CdiscImpactReport"

  def create(results, cls, user, base_url)
    @report = Reports::WickedCore.new
    @report.open("CDISC Impact Report", {}, nil, nil, user, base_url)
    html = body(results, cls)
    @report.html_body(html)
    pdf = @report.save
    return pdf
  end

  if Rails.env == "test"
    # Return the current HTML. Only available for testing.
    #
    # @return [String] The HTML
    def html
      return @report.html
    end
  end

private

  def body(results, cls)
    html = ""
    return html
  end

end
