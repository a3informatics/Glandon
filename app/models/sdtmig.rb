require "uri"

class Sdtmig
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
      
  attr_accessor :id, :name, :managedItem, :domains, :namespace, :files, :type
  validates_presence_of :id, :name, :managedItem, :domains, :namespace, :files, :type
  
  # Constants
  C_NS_PREFIX = "mdrStds"
  C_CLASS_NAME = "Stdmig"
  C_CID_PREFIX = "STD"
  C_SDTM = 1
  C_SDTMIG = 2
  C_UNKNOWN = 3

  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)     
  
  def version
    return self.managedItem.version
  end

  def versionLabel
    return self.managedItem.versionLabel
  end

  def identifier
    return self.managedItem.identifier
  end

  def label
    return self.managedItem.label
  end

  def owner
    return self.managedItem.owner
  end

  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end
  
  def self.find(id, igNamespace)
    
    object = nil
    query = UriManagement.buildNs(igNamespace, ["bo", "bs"]) +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      "  ?a rdf:type bs:SDTMIG . \n" +
      "  ?a bo:name ?b .\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      if uriSet.length == 1 && nameSet.length == 1 
        cid = ModelUtility.extractCid(uriSet[0].text)
        if cid == id
          namespace = ModelUtility.extractNs(uriSet[0].text)
          object = self.new 
          object.id = cid
          object.name = nameSet[0].text
          object.type = C_SDTMIG
          object.namespace = namespace
          object.managedItem = ManagedItem.find(id, namespace)
          object.domains = Domain.findForIg(id, namespace)
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
      end
    end
    return object

  end

  def self.all
    
    ConsoleLogger::log(C_CLASS_NAME,"all","Entry")
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bo", "bs"]) +
      "SELECT ?a ?b ?type WHERE\n" + 
      "{ \n" + 
      "  ?a rdf:type bs:SDTMIG . \n" +
      "  ?a bo:name ?b .\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      ConsoleLogger::log(C_CLASS_NAME,"all","URI=" + uriSet.text)
      if uriSet.length == 1 && nameSet.length == 1 
        id = ModelUtility.extractCid(uriSet[0].text)
        namespace = ModelUtility.extractNs(uriSet[0].text)
        object = self.new 
        object.id = id
        object.name = nameSet[0].text
        object.type = C_SDTMIG
        object.namespace = namespace
        object.managedItem = ManagedItem.find(id, namespace)
        object.domains = Hash.new
        ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + id)
        results[id] = object
      end
    end
    return results  

  end

  def self.create(params)
    
    # TODO: Check for exisitng managed item.

    object = self.new
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    
    namespace = Namespace.findByShortName("CDISC")
    identifier = "SDTM IG"
    itemType = "SDTM_IG"
    version = "1"
    versionLabel = params[:versionLabel]
    files = params[:files]

    # Clean any empty entries
    files.reject!(&:blank?)

    # Create the namespace for the IG
    uri = Uri.new
    uri.setUri(@@baseNs)
    uri.extendPath("/V" + version.to_s)
    igNs = uri.getNs()

    # This needs to be better, wrong namespace at the mo!!!!!
    uri.setUri(Domain.baseNs)
    uri.extendPath("/V" + version.to_s)
    dNs = uri.getNs()
    
    # Upload the file to the database. Send the request, wait the resonse
    ConsoleLogger::log(C_CLASS_NAME,"create","File=" + files[0])
    response = CRUD.file(files[0])

    # Now query the load
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["mms"]) +
      "SELECT ?name ?subject ?domainName ?domainShortName ?dataset WHERE \n" +
      "  { \n" +
      "  ?subject rdf:type mms:Column . \n" +
      "  ?subject mms:dataElementName ?name . \n" +
      "  ?subject mms:context ?dataset . \n" +
      "  ?dataset mms:contextLabel ?domainName .  \n" +
      "  ?dataset mms:contextName ?domainShortName .  \n" +
      "  } ORDER BY ?domainName"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    directory = Rails.root.join("public","upload")
    path = File.join(directory, "sdtmigExport.xml")
    File.open(path, "wb") do |f|
       xmlDoc.write_xml_to f
    end

    # Transform the files and upload. Note the quotes around the strings parameters.
    Xslt.execute(path, "sdtmig/import/cdiscSdtmigImport.xsl", {:InternalVersion => version.to_s, :SDTMVersion => "'" + versionLabel.to_s + "'",
       :IGNamespace => "'" + igNs + "'", :DNamespace => "'" + dNs + "'"}, "sdtmig.ttl")
    
    # upload the file to the database. Send the request, wait the resonse
    publicDir = Rails.root.join("public","upload")
    outputFile = File.join(publicDir, "sdtmig.ttl")
    response = CRUD.file(outputFile)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create","Succes")  
    else
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
    
    return nil

  end

  def update
    return nil
  end

  def destroy
     return nil    
  end

private

  def self.getType (uri)
 
    ConsoleLogger::log(C_CLASS_NAME,"getType","uri=" + uri)
    type = ModelUtility.extractCid(uri)
    ConsoleLogger::log(C_CLASS_NAME,"getType","type=" + type)
    if type == "SDTM"
      type = C_SDTM
    elsif type == "SDTMIG"
      type = C_SDTMIG
    else
      type = C_UNKNOWN
    end
    return type
  
   end  
end
