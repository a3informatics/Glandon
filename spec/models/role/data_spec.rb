require 'rails_helper'

describe Role do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/role"
  end

  describe "Create Role Data" do
  
    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    it "creates roles" do
      roles = 
      [
        {  
          name: "sys_admin",
          display_text: "System Admin",
          description: "System administration rights. This role has no access to MDR content.",
          system_admin: true,
          enabled: true,
          combined_with: []
        },
        {  
          name: "community_reader",
          display_text: "Community Reader",
          description: "Specific role for use with the community version. Can be used as a simple reader role.",
          system_admin: false,
          enabled: true,
          combined_with: []
        },
        {  
          name: "term_reader",
          display_text: "Terminology Reader",
          description: "The lowest level of access. A Terminology Reader access permits the user to have read-only access to the MDR's terminology content.",
          system_admin: false,
          enabled: true,
          combined_with: [] 
        },
        {  
          name: "term_curator",
          display_text: "Terminology Curator",
          description: "Terminology Curator access permits the user to have read and write access to the MDR's terminology content.",
          system_admin: false,
          enabled: true,
          combined_with: [] 
        },
        {  
          name: "reader",
          display_text: "Reader",
          description: "Reader access permits the user to have read-only access to all of the MDR's content.",
          system_admin: false,
          enabled: true,
          combined_with: [] 
        },
        {  
          name: "curator",
          display_text: "Curator",
          description: "Curator access permits the user to have view access to the MDR's content while also being able to edit the content.",
          system_admin: false,
          enabled: true,
          combined_with: [] 
        },
        {  
          name: "content_admin",
          display_text: "Content Admin",
          description: "The highest level of access. Content administration access permits the user to have view access to the MDR's content, allows for the editing of the content and permits new content to be imported.",
          system_admin: true,
          enabled: true,
          combined_with: [] 
        }
      ]
      sys_admin = nil
      sparql = Sparql::Update.new
      sparql.default_namespace(Role.rdf_type.namespace)
      roles.each do |role|
        object = Role.new(role)
        object.uri = object.create_uri(Role.base_uri)  
        sys_admin = object if role[:name] == "sys_admin"
        object.combined_with_push(sys_admin) if role[:system_admin] && !sys_admin.nil?
        object.to_sparql(sparql)
      end
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_roles.ttl")
    end

  end

  describe "Create Role Data" do
  
    before :all do
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_4.ttl")
      load_data_file_into_triple_store("mdr_roles.ttl")
    end

    it "creates role permissions" do
      objects = []
      access_nodes = {}
      role_permissions = {}
      permissions = 
      {
        Thesaurus::ManagedConcept.rdf_type.to_s => 
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: true, update: false, delete: false},
            term_reader:  {create: false, read: true, update: false, delete: false},
            term_curator: {create: true, read: true, update: true, delete: true},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        BiomedicalConceptTemplate.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        BiomedicalConceptInstance.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        Form.rdf_type.to_s => 
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        SdtmModel.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        SdtmIg.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        SdtmIgDomain.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        SdtmClass.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        AdamIg.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        AdamIgDataset.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        SdtmSponsorDomain.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        IsoConceptV2.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        IsoNamespace.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        IsoScopedIdentifierV2.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        IsoRegistrationAuthority.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          },
        IsoRegistrationStateV2.rdf_type.to_s =>
          {
            sys_admin: {create: false, read: false, update: false, delete: false},
            community_reader: {create: false, read: false, update: false, delete: false},
            term_reader:  {create: false, read: false, update: false, delete: false},
            term_curator: {create: false, read: false, update: false, delete: false},
            reader: {create: false, read: true, update: false, delete: false},
            curator: {create: true, read: true, update: true, delete: true},
            content_admin: {create: true, read: true, update: true, delete: true}
          }
      }
      access_nodes[:create] = IsoConceptSystem.path(["CRUD", "CREATE"])
      access_nodes[:read] = IsoConceptSystem.path(["CRUD", "READ"])
      access_nodes[:update] = IsoConceptSystem.path(["CRUD", "UPDATE"])
      access_nodes[:delete] = IsoConceptSystem.path(["CRUD", "DELETE"])
      sparql = Sparql::Update.new
      sparql.default_namespace(Role.rdf_type.namespace)
      roles = Role.all
      permissions.each do |klass, permission_set|
        roles.each do |role|
          [:create, :read, :update, :delete].each do |access_type|
            next unless permission_set[role.name.to_sym][access_type]
            rp = role_permissions.dig(klass.to_s, access_type)
            if rp.nil?
              rp = Role::Permission.new(for_role: [], for_class: Uri.new(uri: klass), with_access: access_nodes[access_type]) 
              role_permissions[klass] = {} unless role_permissions.key?(klass)
              role_permissions[klass][access_type] = rp
              objects << rp
            end
            rp.for_role_push(role)
          end
        end
      end
      objects.each do |object|
        object.uri = object.create_uri(Role::Permission.base_uri)  
        object.to_sparql(sparql)
      end
      file = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", file.basename, sub_dir, "mdr_role_permissions.ttl")
    end

  end

end
