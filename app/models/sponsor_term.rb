require "nokogiri"
require "uri"

class SponsorTerm
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
  include ModelUtility
      
  attr_accessor :id, :files, :thesaurus
  validates_presence_of :files, :thesaurus
  
  # Constants
  C_NS_PREFIX = "thS"
  C_CLASS_NAME = "SponsorTerm"
  
  # Class-wide variables
  @@organization = nil # CDISC Organization identifier
  @@currentVersionId = nil # The namespace for the current term version
    
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
    if @@organization == nil 
      @@organization = IsoNamespace.findByShortName("ACME")
    end
    tSet = Thesaurus.findByNamespaceId(@@organization.id)
    tSet.each do |thesaurus|
      object = self.new 
      object.id = thesaurus.id
      object.thesaurus = thesaurus
      results.push(object)
    end
    results.sort! { |a,b| a.thesaurus.managedItem.versionLabel <=> b.thesaurus.managedItem.versionLabel }
    return results  
    
  end
  
  def self.current 
    ConsoleLogger::log(C_CLASS_NAME,"Current","*****ENTRY*****")
    object = nil
    if @@currentVersionId == nil
      ConsoleLogger::log(C_CLASS_NAME,"Current","Current nil")
      latest = nil
      if @@organization == nil 
        @@organization = IsoNamespace.findByShortName("ACME")
      end
      tSet = Thesaurus.findByNamespaceId(@@organization.id)
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
      @@currentVersionId = object.id
    else
      ConsoleLogger::log(C_CLASS_NAME,"Current","CurrentVersionId=" + @@currentVersionId)
      object = self.find(@@currentVersionId)
    end
    ConsoleLogger::log(C_CLASS_NAME,"Current","*****EXIT***** " + object.id)   
    return object
  end
  
  def self.create(params)
    
    thesaurus = Thesaurus.createLocal(params)
    object = self.new 
    object.id = thesaurus.id
    object.thesaurus = thesaurus
    return object
    
  end

  def update
    return nil
  end

  def destroy    
  end
  
end
