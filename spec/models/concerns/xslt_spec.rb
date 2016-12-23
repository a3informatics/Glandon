require 'rails_helper'

describe Xslt do
	
  include PublicFileHelpers

	it "executes a transform" do
    delete_public_file("upload", "CT_V99.ttl")
    copy_file_to_public_files("models/concerns", "cdiscImportManifest.xml", "upload")
    copy_file_to_public_files("models/concerns", "SDTM_2016-09-30.owl", "upload")
    filename = "CT_V99.ttl"
    params = 
    { 
      :UseVersion => 99, 
      :Namespace => "'http://www.assero.co.uk/MDRThesaurus/CDISC/V99'", 
      :SI => "'SI-CDISC_CDISCTerminology-99'", 
      :RS => "'RS-CDISC_CDISCTerminology-99'", 
      :CID => "'TH-CDISC_CDISCTerminology'"
    }
    directory = Rails.root.join("public","upload")
    manifest = File.join(directory, "cdiscImportManifest.xml")
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", params, filename)
    expect(File.exists?(Rails.root.join "public/upload/CT_V99.ttl")).to be(true)
	end

end