# User Role. Mixin to handle role related processing
#
# @author Dave Iberson-Hurst
# @since 4.0.0
class User

  module Role

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # None yet.
    end

    # ----------------
    # Instance Methods
    # ----------------

    # Add Role
    #
    # @param [Symbol] role the role as a symbol. Must match the role name in the database.
    # @raise [Errors::ApplicationLogicError] raised if failed to find role or user access nodes
    # @return [Boolean] true
    def add_role(role)
      role = ::Role.where_only(name: "#{role}")
      ua = ::User::Access.where_only(user_id: self.id)
      Errors.application_error(self.class.name, "add_role", "Role not found when adding a user role: #{role}.") if role.nil?
      Errors.application_error(self.class.name, "add_role", "User access node not found when adding a user role.") if ua.nil?
      ua.properties.property(:has_role).replace_with_object(role)
      true
    end

    # Has Role? Does the user have the specified role?
    #
    # @param [Symbol] role the role as a symbol. Must match the role name in the database.
    # @return [Boolean] true if user has role, otherwise false.
    def has_role?(role)
      Sparql::Query.new.query("ASK {?s rdf:type usr:UserAccess . ?s usr:user_id #{self.id}^^xsd:integer . ?s usr:hasRole ?r . ?r use:name '#{role}'^^xsd:string", "", [:usr]).ask? 
    end

    # Single Role? Does the user only have a single role?
    #
    # @param [Symbol] role the role as a symbol. Must match the role name in the database.
    # @return [Boolean] true if user has single role, otherwise false.
    def single_role?(role)
      Sparql::Query.new.query("SELECT DISTINCT ?r WHERE {?s rdf:type usr:UserAccess . ?s usr:user_id #{self.id}^^xsd:integer . ?s usr:hasRole ?r", "", [:usr]).results.count == 1 
    end

    # Allocated Roles. Roles allocated to the user as array of symbols.
    #
    # @return [Array] array of symbols for the allocated roles.
    def allocated_roles
      result = []
      query_results = Sparql::Query.new.query("SELECT DISTINCT ?s ?p ?o WHERE {?x rdf:type usr:UserAccess . ?x usr:user_id #{self.id}^^xsd:integer . ?x usr:hasRole ?s . ?s ?p ?o", "", [:usr])
      query_results.by_subject.each do |subject, triples|
        result << Role.from_results(Uri.new(uri: subject), triples)
      end
      result
    end

    # User roles as an array of strings
    #
    # @return [array] Array of roles (strings)
    def role_list
      result = []
      allocated_roles.map { |x| result << x.display_name }
      result
    end

    # User roles stripped
    #
    # @return [array] Array of roles (strings)
    def role_list_stripped
      "#{self.role_list}".gsub(/[^A-Za-z, ]/, '')
    end

  end

end
