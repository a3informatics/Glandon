require "uri"

class CdiscTerm
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
      
  attr_accessor :id, :files, :identifier, :version, :date, :namespace, :thesaurus_id
  validates_presence_of :files, :date, :namespace, :thesaurus_id
  
  # Base namespace 
  @@cdiscOrg # CDISC Organization identifier
  
  def persisted?
    id.present?
  end
  
  def ns
    
    return @namespace
    
  end
  
  def name
    
    if self.thesaurus_id == nil
      return ""
    else
      thesaurus = Thesaurus.find(self.thesaurus_id)
      return thesaurus.name
    end
    
  end
  
  def identifier
    
    if self.thesaurus_id == nil
      return ""
    else
      thesaurus = Thesaurus.find(self.thesaurus_id)
      return thesaurus.identifier
    end
    
  end
  
  def version
    
    if self.thesaurus_id == nil
      return ""
    else
      thesaurus = Thesaurus.find(self.thesaurus_id)
      return thesaurus.version
    end
    
  end
  
  def self.find(id)
    return Thesaurus.find(id)
  end

  def self.all
    
    results = Array.new
    @@cdiscOrg = Organization.findByShortName("CDISC")
    tSet = Thesaurus.findByOrgId(@@cdiscOrg.id)
    tSet.each do |thesaurus|
      object = self.new 
      object.id = thesaurus.id
      object.thesaurus_id = thesaurus.id
      results.push(object)
    end
    return results  
    
  end

  def self.create(params)
    
    object = self.new
    
    org = Organization.findByShortName("CDISC")
    identifier = "CDISC Terminology"
    version = params[:version]
    date = params[:date]
    files = params[:files]

    # Clean any empty entries
    files.reject!(&:blank?)
    
    # Create manifest file
    manifest = Xml::buildCdiscTermImportManifest(date, version, files)
    
    # Create the IdentifiedItem
    iiParams = {:version => version, :shortName => "CDISC_CT",:identifier => identifier, :organization_id => org.id}
    ii = IdentifiedItem.create(iiParams)
    
    #Create the thesaurus
    ns = Thesaurus.ns
    
    p = "Namespace=" + ns
    
    uri = Uri.new
    uri.setUri(ns)
    uri.extendPath("CDISC/V" + version)
    prefix = "thCv" + version
    ns = uri.getNS()
    Namespace.add(prefix, ns)
    
    p = "Namespace=" + ns
    p = "Prefix=" + prefix
    
    tParams = {:ii_id => ii.id}
    nsParams = {:prefix => prefix, :value => ns}
    thesaurus = Thesaurus.create(tParams, nsParams)
    
    # Transform the files and upload. Note the quotes around the namespace, important!!
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", {:UseVersion => version, :Namespace => "'" + ns + "'", :II => ii.id}, "CT.ttl")
    
    # upload the file to the database
    # Send the request, wait the resonse
    publicDir = Rails.root.join("public","upload")
    outputFile = File.join(publicDir, "CT.ttl")
    response = CRUD.turtleFile(outputFile)

    # Response
    if response.success?
      p "It worked!"
    else
      p "It didn't work!"
    end
    
    # Set the object
    object.date = date
    object.version = version
    object.identifier = identifier
    object.namespace = ns
    object.thesaurus_id = thesaurus.id
    return object
    
  end

  def update
    return nil
  end

  def destroy
         
  end
  
end
