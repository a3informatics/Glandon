class Role < Fuseki::Base

  configure rdf_type: 'http://www.a3informatics.com/rdf-schema/users-and-roles#Role',
            base_uri: "http://#{ENV["url_authority"]}/ROLE",
            uri_unique: true

  data_property :name
  data_property :display_text
  data_property :description
  data_property :enabled, default: true
  data_property :system_admin, default: false
  object_property :combined_with, cardinality: :many, model_class: "Role"

  validates_with Validator::Field, attribute: :name, method: :valid_short_name?
  validates_with Validator::Field, attribute: :display_text, method: :valid_short_name?
  validates_with Validator::Field, attribute: :description, method: :valid_label?
  validates :enabled, inclusion: { in: [ true, false ] }
  validates :system_admin, inclusion: { in: [ true, false ] }

  # With System Admin
  #
  # @param [string] role the name of the role
  # @return [Boolean] return true if role can be combined with the system admin role.
  def self.with_sys_admin(role)
  	roles = Role.all
    role = roles.find{|x| x.name == role}
    return false if role.nil?
    return role.combined_with_objects.map{|x| x.system_admin}.any?
  end

  # Description
  #
  # @param [string] role the name of the role
  # @return [String] returns the role description if role valid else blank.
  def self.description(role)
    roles = Role.where(name: role)
    roles.any? ? roles.first.description : ""
  end

  # To Display. Return role as a human readable string
  #
  # @param [string] role the name of the role
  # @param [Symbol] role the role
  # @return [String] The role string if found, otherwise empty
  def self.to_display(role)
    roles = Role.where(name: role)
    roles.any? ? roles.first.display_text : ""
  end

  # List. Get a list of roles, id and display text
  #
  # @return [Hash] hash of ids for the role names
  def self.list
    results = {}
    Role.all.each do |x|
     results[x.name.to_sym] = { id: x.id, display_text: x.display_text }
    end
    return results
  end

  # All. Get all the roles
  #
  # @return [Array] array of role objects
  def self.all
    results = []
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        ?s rdf:type usr:Role . 
        ?s ?p ?o
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:usr])
    query_results.by_subject.each do |subject, triples|
      results << Role.from_results(Uri.new(uri: subject), triples)
    end
    results
  end

end
