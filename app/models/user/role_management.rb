# User Role. Mixin to handle role related processing
#
# @author Dave Iberson-Hurst
# @since 4.0.0
class User

  module RoleManagement

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      # Restore Roles and Scopes. Restore the role and scopes from the backup.
      #
      # @return [Boolean] always returns true
      def restore_roles_and_scopes
        return unless User::Access.all.empty?
        User.all.each do |user|
          ua = User::Access.new
          ua.uri = ua.create_uri(ua.class.base_uri)
          ua.user_id = user.id
          roles = user.read_setting(:roles).value.split("|")
          roles.each do |item|
            ua.has_role_push(Uri.new(uri: item))
          end
          # Scopes not tested yet
          #scopes = read_setting(:scopes).split("|")
          #scopes.each do |item|
          #  ua.can_access_scope_push(Uri.new(uri: item))
          #end
          ua.save
        end
        true
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Save Roles and Scopes. Save the role and scopes as a backup.
    #
    # @return [Boolean] always returns true
    def save_roles_and_scopes
      ua = my_access
      Errors.application_error(self.class.name, "save_roles_and_scopes", "User access node not found when saving roles and scopes.") if ua.nil?
      write_setting(:roles, ua.has_role.map{|x| "#{x}"}.join("|"))
      # Scopes not tested yet
      #write_setting(:scopes, ua.can_access_scope.map{|x| "#{x}"}.join("|"))
      true
    end

    # My Access. Return the User::Access object for this user.
    #
    # @return [User::Access] the user access object. Might be nil.
    def my_access
      ::User::Access.where_only(user_id: self.id)
    end
      
    # Add Role. Adds Role to a user. Creates the User Acess node if required. The role must exist.
    #
    # @param [Symbol] role_name the role as a symbol. Must match the role name in the database.
    # @raise [Errors::ApplicationLogicError] raised if failed to find role or user access nodes.
    # @return [Boolean] true unless exception raised
    def add_role(role_name)
      role = ::Role.where_only(name: "#{role_name}")
      ua = ::User::Access.where_only_or_create({user_id: self.id}, {user_id: self.id})
      Errors.application_error(self.class.name, "add_role", "Role not found when adding a user role: #{role_name}.") if role.nil?
      Errors.application_error(self.class.name, "add_role", "User access node not found when adding a user role.") if ua.nil?
      ua.properties.property(:has_role).replace_with_object(role)
      ua.save
      true
    end

    # Remove Role. Adds Role to a user. Creates the User Acess node if required. The role must exist.
    #
    # @param [Symbol] role_name the role as a symbol. Must match the role name in the database.
    # @raise [Errors::ApplicationLogicError] raised if failed to find role or user access nodes.
    # @return [Boolean] true unless exception raised
    def remove_role(role_name)
      role = ::Role.where_only(name: "#{role_name}")
      ua = my_access
      Errors.application_error(self.class.name, "remove_role", "Role not found when adding a user role: #{role_name}.") if role.nil?
      Errors.application_error(self.class.name, "remove_role", "User access node not found when adding a user role.") if ua.nil?
      ua.properties.property(:has_role).delete_value(role)
      ua.save
      true
    end

    # Has Role? Does the user have the specified role?
    #
    # @param [Symbol] role the role as a symbol. Must match the role name in the database.
    # @return [Boolean] true if user has role, otherwise false.
    def has_role?(role)
      Sparql::Query.new.query("ASK {?s rdf:type usr:UserAccess . ?s usr:userId '#{self.id}'^^xsd:integer . ?s usr:hasRole ?r . ?r usr:name '#{role}'^^xsd:string }", "", [:usr]).ask? 
    end

    # Single Role? Does the user only have a single role?
    #
    # @return [Boolean] true if user has single role, otherwise false.
    def single_role?
      Sparql::Query.new.query("SELECT DISTINCT ?r WHERE {?s rdf:type usr:UserAccess . ?s usr:userId '#{self.id}'^^xsd:integer . ?s usr:hasRole ?r }", "", [:usr]).results.count == 1 
    end

    # Allocated Roles. Roles allocated to the user as array of symbols.
    #
    # @return [Array] array of Role objects for the allocated roles.
    def allocated_roles
      result = []
      query_results = Sparql::Query.new.query("SELECT DISTINCT ?s ?p ?o WHERE {?x rdf:type usr:UserAccess . ?x usr:userId '#{self.id}'^^xsd:integer . ?x usr:hasRole ?s . ?s ?p ?o }", "", [:usr])
      query_results.by_subject.each do |subject, triples|
        result << Role.from_results(Uri.new(uri: subject), triples)
      end
      result
    end

    # Allocated Roles Names. Roles allocated to the user as array of symbols.
    #
    # @return [Array] array of symbols for the allocated roles.
    def allocated_role_names
      allocated_roles.sort_by{|x| x.name}.map{|x| x.name.to_sym}
    end

    # User roles as an array of strings
    #
    # @return [array] Array of roles (strings)
    def role_list
      result = []
      allocated_roles.map { |x| result << x.display_text }
      result
    end

    # User roles stripped
    #
    # @return [array] Array of roles (strings)
    def role_list_stripped
      "#{self.role_list.sort}".gsub(/[^A-Za-z, ]/, '')
    end

  end

end
