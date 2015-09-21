require "nokogiri"

module Xml

  def Xml.buildCdiscTermImportManifest(date, version, files)

    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|

      xml.CDISCTerminology() {
        xml.Update(:date => date, :version => version) {
          files.each do |file|
            xml.File(:filename => file) 
          end
        }
      }
  
    end

    p "Manifest XML=" + builder.to_xml
    
    directory = Rails.root.join("public","upload")
    path = File.join(directory, "cdiscImportManifest.xml")
    File.open(path, "wb") do |f|
       f.write(builder.to_xml)
    end
    
    return path
    
  end

end
