require "nokogiri"
require "uri"

class CdiscTerm
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
  include ModelUtility
      
  attr_accessor :id, :files, :thesaurus
  validates_presence_of :files, :thesaurus
  
  # Constants
  C_NS_PREFIX = "thC"
  C_CLASS_NAME = "CdiscTerm"
  
  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  @@currentVersion = nil # The namespace for the current term version
    
  # Base namespace 
  @@baseNs = Thesaurus.baseNs()
  
  def version
    return self.thesaurus.managedItem.version
  end

  def versionLabel
    return self.thesaurus.managedItem.versionLabel
  end

  def identifier
    return self.thesaurus.managedItem.identifier
  end

  def namespace
    return self.thesaurus.namespace
  end

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
    object.thesaurus = thesaurus
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + object.id)
    return object

  end

  def self.searchText(searchTerm)

    currentCdiscTerm = current()
    ConsoleLogger::log(C_CLASS_NAME,"searchText","Id=" + currentCdiscTerm.id + ", term=" + searchTerm)
    results = ThesaurusConcept.searchTextWithNs(currentCdiscTerm.id, currentCdiscTerm.namespace, searchTerm)
    return results

  end

  def self.searchIdentifier(searchTerm)

    currentCdiscTerm = current()
    ConsoleLogger::log(C_CLASS_NAME,"searchIdentifier","Id=" + currentCdiscTerm.id + ", term=" + searchTerm)
    results = ThesaurusConcept.searchIdentifierWithNs(currentCdiscTerm.id, currentCdiscTerm.namespace, searchTerm)
    return results

  end

  def self.all
    
    results = Array.new
    if @@cdiscNamespace == nil 
      @@cdiscNamespace = Namespace.findByShortName("CDISC")
    end
    tSet = Thesaurus.findByNamespaceId(@@cdiscNamespace.id)
    tSet.each do |thesaurus|
      object = self.new 
      object.id = thesaurus.id
      object.thesaurus = thesaurus
      results.push(object)
    end
    results.sort! { |a,b| a.thesaurus.managedItem.versionLabel <=> b.thesaurus.managedItem.versionLabel }
    return results  
    
  end

  def self.allExcept(version)
    
    results = Array.new
    if @@cdiscNamespace == nil 
      @@cdiscNamespace = Namespace.findByShortName("CDISC")
    end
    tSet = Thesaurus.findByNamespaceId(@@cdiscNamespace.id)
    tSet.each do |thesaurus|
      if (version != thesaurus.internalVersion)
        object = self.new 
        object.id = thesaurus.id
        object.thesaurus = thesaurus
        results.push(object)
      end
    end
    results.sort! { |a,b| a.thesaurus.managedItem.version <=> b.thesaurus.managedItem.version }
    return results  
    
  end
  
  def self.allPrevious(version)
    
    results = Array.new
    if @@cdiscNamespace == nil 
      @@cdiscNamespace = Namespace.findByShortName("CDISC")
    end
    tSet = Thesaurus.findByNamespaceId(@@cdiscNamespace.id)
    tSet.each do |thesaurus|
      if (version > thesaurus.managedItem.version)
        object = self.new 
        object.id = thesaurus.id
        object.thesaurus = thesaurus
        results.push(object)
      end
    end
    results.sort! { |a,b| a.thesaurus.managedItem.version <=> b.thesaurus.managedItem.version }
    return results  
    
  end
  
  def self.current 
    ConsoleLogger::log(C_CLASS_NAME,"Current","*****ENTRY*****")
    object = nil
    if @@currentVersion == nil
      ConsoleLogger::log(C_CLASS_NAME,"Current","Current nil")
      latest = nil
      if @@cdiscNamespace == nil 
        @@cdiscNamespace = Namespace.findByShortName("CDISC")
      end
      tSet = Thesaurus.findByNamespaceId(@@cdiscNamespace.id)
      tSet.each do |thesaurus|
        if latest == nil
          latest = thesaurus
        elsif thesaurus.version > latest.version
          latest = thesaurus
        end
      end
      object = self.new 
      object.id = latest.id
      object.thesaurus = latest
      @@currentVersion = object
    else
      ConsoleLogger::log(C_CLASS_NAME,"Current","CurrentVersion Id=" + @@currentVersion.id)
      object = @@currentVersion
    end
    ConsoleLogger::log(C_CLASS_NAME,"Current","*****EXIT***** " + object.id)   
    return object
  end
  
  def self.create(params)
    
    object = self.new
    
    namespace = Namespace.findByShortName("CDISC")
    identifier = "CDISC Terminology"
    version = params[:version]
    date = params[:date]
    files = params[:files]

    # Clean any empty entries
    files.reject!(&:blank?)
    
    # Create manifest file
    manifest = Xml::buildCdiscTermImportManifest(date, version, files)
    
    #Create the thesaurus
    baseNs = Thesaurus.baseNs
    uri = Uri.new
    uri.setUri(baseNs)
    uri.extendPath("CDISC/V" + version)
    ns = uri.getNs()
    tParams = {:versionLabel => date.to_s, :itemType => "CDISC_CT", :version => version, :identifier => identifier, :namespaceId => namespace.id}
    thesaurus = Thesaurus.createImported(tParams, ns)
    si = thesaurus.managedItem.scopedIdentifier.id
    
    # Transform the files and upload. Note the quotes around the namespace & II but not version, important!!
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", {:UseVersion => version, :Namespace => "'" + ns + "'", :SI => "'" + si + "'"}, "CT.ttl")
    
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
    object.thesaurus = thesaurus
    object.id = thesaurus.id
    return object
    
  end

  def update
    return nil
  end

  def destroy
         
  end
  
end
