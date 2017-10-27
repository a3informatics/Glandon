module PermissionsHelpers

  def allow(action)
    expect(subject.public_send("#{action}?")).to eq(true)
  end

  def deny(action)
    expect(subject.public_send("#{action}?")).to eq(false)
  end

  def allow_list(action_list, display=false)
    action_list.each do |action|
    	puts "#{action}" if display
      allow(action)
    end
  end

  def deny_list(action_list, display=false)
    action_list.each do |action|
    	puts "#{action}" if display
      deny(action)
    end
  end

  def construct_roles  
  	return ["sys_admin", "term_reader", "term_curator", "reader", "curator", "content_admin"]
  end

  def construct_roles_to_user
  	return { "sys_admin" => @user_sa, "term_reader" => @user_tr, "term_curator" => @user_tc, "reader" => @user_r, 
  		"curator" => @user_c, "content_admin" => @user_ca }
  end

  def contruct_default_list
  	results = {}
  	read_actions = [ "index", "show", "view", "all", "list", "history" ]
    edit_actions = [ "create", "new", "update", "edit", "clone", "branch", "upgrade", "impact", "destroy", "export_json", "export_ttl", "export_csv" ]
    content_admin_actions = [ "import" ]
    all_actions = read_actions + edit_actions
    no_actions = []
    results["sys_admin"] = { allow: [], deny: all_actions } 
    results["term_reader"] = { allow: no_actions, deny: edit_actions } 
    results["term_curator"] = { allow: no_actions, deny: edit_actions } 
    results["reader"] = { allow: read_actions, deny: edit_actions + content_admin_actions } 
    results["curator"] = { allow: read_actions + edit_actions, deny: content_admin_actions } 
    results["content_admin"] = { allow: all_actions, deny: [] } 
		return results
  end

  # Don't Use - Reads config file
  def contruct_list(klass)
  	results = {}
  	Rails.configuration.roles["roles"].each { |k, v| results[k] = { allow: [], deny: [] } }
		contruct_list_for_class(ApplicationPolicy, results)
		contruct_list_for_class(klass, results) if Rails.configuration.policy.has_key?(klass)
		return results
  end

  # Don't Use - Reads config file
  def contruct_list_for_class(klass, results)
	  Rails.configuration.policy[klass.to_s].each do |action, role_permission| 
			role_permission.each do |role, permission|
  			results[role][:allow] << action if permission
  			results[role][:deny] << action if !permission
  		end
		end
	end

end