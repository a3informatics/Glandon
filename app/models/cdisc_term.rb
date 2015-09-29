require "uri"

class CdiscTerm
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
      
  attr_accessor :id, :files, :date, :thesaurus_id, :identifier, :version, :namespace
  validates_presence_of :files, :date, :thesaurus_id, :identifier, :version, :namespace
  
  # Constants
  C_NS_PREFIX = "thC"
  
  # Base namespace 
  @@cdiscOrg # CDISC Organization identifier
  
  # Base namespace 
  @@BaseNs = Thesaurus.baseNs()
  
  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end
  
  def self.find(id)

    thesaurus = Thesaurus.findWithoutNs(id)
    object = self.new 
    object.id = thesaurus.id
    object.thesaurus_id = thesaurus.id
    object.date = thesaurus.created
    object.identifier = thesaurus.identifier
    object.version = thesaurus.version
    object.namespace = thesaurus.namespace
    return object

  end

  def self.all
    
    results = Array.new
    @@cdiscOrg = Organization.findByShortName("CDISC")
    tSet = Thesaurus.findByOrgId(@@cdiscOrg.id)
    tSet.each do |thesaurus|
      object = self.new 
      object.id = thesaurus.id
      object.thesaurus_id = thesaurus.id
      object.date = thesaurus.created
      object.identifier = thesaurus.identifier
      object.version = thesaurus.version
      object.namespace = thesaurus.namespace
      results.push(object)
    end
    results.sort! { |a,b| a.version <=> b.version }
    return results  
    
  end

  def self.allExcept(version)
    
    results = Array.new
    @@cdiscOrg = Organization.findByShortName("CDISC")
    tSet = Thesaurus.findByOrgId(@@cdiscOrg.id)
    tSet.each do |thesaurus|
      if (version != thesaurus.version)
        object = self.new 
        object.id = thesaurus.id
        object.thesaurus_id = thesaurus.id
        object.date = thesaurus.created
        object.identifier = thesaurus.identifier
        object.version = thesaurus.version
        object.namespace = thesaurus.namespace
        results.push(object)
      end
    end
    results.sort! { |a,b| a.version <=> b.version }
    return results  
    
  end
  
  def self.allPrevious(version)
    
    results = Array.new
    @@cdiscOrg = Organization.findByShortName("CDISC")
    tSet = Thesaurus.findByOrgId(@@cdiscOrg.id)
    tSet.each do |thesaurus|
      if (version > thesaurus.version)
        object = self.new 
        object.id = thesaurus.id
        object.thesaurus_id = thesaurus.id
        object.date = thesaurus.created
        object.identifier = thesaurus.identifier
        object.version = thesaurus.version
        object.namespace = thesaurus.namespace
        results.push(object)
      end
    end
    results.sort! { |a,b| a.version <=> b.version }
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
    baseNs = Thesaurus.baseNs
    uri = Uri.new
    uri.setUri(baseNs)
    uri.extendPath("CDISC/V" + version)
    ns = uri.getNs()
    tParams = {:ii_id => ii.id, :created => date}
    thesaurus = Thesaurus.create(tParams, ns)
    
    # Transform the files and upload. Note the quotes around the namespace & II but not version, important!!
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", {:UseVersion => version, :Namespace => "'" + ns + "'", :II => "'" + ii.id + "'"}, "CT.ttl")
    
    # upload the file to the database. Send the request, wait the resonse
    publicDir = Rails.root.join("public","upload")
    outputFile = File.join(publicDir, "CT.ttl")
    response = CRUD.file(outputFile)

    # Response
    if response.success?
      p "It worked!"
    else
      p "It didn't work!"
    end
    
    # Set the object
    object.date = date
    object.thesaurus_id = thesaurus.id
    object.id = thesaurus.id
    object.date = date
    object.identifier = thesaurus.identifier
    object.version = thesaurus.version
    object.namespace = ns
    return object
    
  end

  def update
    return nil
  end

  def destroy
         
  end
  
end
