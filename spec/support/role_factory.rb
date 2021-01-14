module RoleFactory
  
  def create_role(params)
    data = [
      {key: :name, value: "ROLE"}, 
      {name: :display_text, value: "display_text"},
      {name: :description, value: "A description for testing"},
      {name: :enabled, value: true},
      {name: :system_admin, value: false},
      {name: :combined_with, value: []},
    ]
    fill_params(params, data)
    Role.create(params)
  end

end