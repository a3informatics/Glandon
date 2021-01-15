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
      
      if Rails.env.test? || Rails.env.development?

        # Restore roles and scopes
        def restore_roles_and_scopes
          return if User::Access.all.count.empty?
          Users.all.each do |user|
            ua = User::Access.new
            us.user_id = user.id
            access = read_setting(:roles_and_scopes).split("|")
            access.each do |item|
              if item.start_with?('s:')
                ua.can_access_scope_push(Uri.new(uri: item[2..-1]))
              elsif item.start_with?('r:')
                ua.has_role_push(Uri.new(uri: item[2..-1]))
              end
            end
          end
        end

      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    if Rails.env.test? || Rails.env.development?

      # Save roles and scopes
      def save_roles_and_scopes
        ua = my_access
        Errors.application_error(self.class.name, "save_roles_and_scopes", "User access node not found when adding a user role.") if ua.nil?
        settings = ua.can_access_scope.map{|x| "s:#{x}"} + ua.has_role.map{|x| "r:#{x}"}
        write_setting(:roles_and_scopes, settings.join("|"))
      end

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
