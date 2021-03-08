module ApplicationHelper

  @@id_to_type_map = {
    dashboard: {link: "#", text: "Dashboard"},
    iso_namespaces: {link: "/iso_namespaces", text: "Namespaces"},
    iso_registration_authorities: {link: "/iso_registration_authorities", text: "Registration Authorities"},
    iso_managed: {link: "/iso_managed", text: "Managed Items"},
    tokens: {link: "/tokens", text: "Edit Locks"},
    audit_trail: {link: "/audit_trail", text: "Audit trail"},
    uploads: {link: "/uploads", text: "Upload"},
    imports: {link: "/imports/list", text: "Import"},
    exports: {link: "/exports", text: "Export"},
    backgrounds: {link: "/backgrounds", text: "Background Jobs"},
    ad_hoc_reports: {link: "/ad_hoc_reports", text: "Ad Hoc Reports"},
    iso_concept_systems: {link: "/iso_concept_systems", text: "Tags"},
    markdown_engines: {link: "/markdown_engines", text: "Markdown"},
    thesauri: {link: "/thesauri", text: "Terminology", icon: "icon-terminology"},
    cdisc_terms: {link: "/cdisc_terms/history", text: "CDISC Terminology", icon: "icon-terminology"},
    code_lists: {link: "/thesauri/managed_concepts", text: "Code Lists", icon: "icon-codelist"},
    biomedical_concept_templates: {link: "/biomedical_concept_templates", text: "Biomedical Concept Templates"},
    biomedical_concept_instances: {link: "/biomedical_concept_instances", text: "Biomedical Concepts", icon: "icon-biocon"},
    forms: {link: "/forms", text: "Forms", icon: "icon-forms"},
    sdtm_models: {link: "/sdtm_models/history", text: "CDISC SDTM Model", icon: "icon-sdtm"},
    sdtm_igs: {link: "/sdtm_igs/history", text: "CDISC SDTM IGs", icon: "icon-sdtm"},
    sdtm_ig_domains: {link: "/sdtm_ig_domains", text: "SDTM IG Domains", icon: "icon-sdtm"},
    sdtm_sponsor_domains: {link: "/sdtm_sponsor_domains", text: "SDTM Sponsor Domains", icon: "icon-sdtm"},
    sdtm_classes: {link: "/sdtm_classes", text: "Classes", icon: "icon-sdtm"},
    adam_igs: {link: "/adam_igs/history", text: "CDISC ADaM IGs", icon: "icon-sdtm"},
    adam_ig_datasets: {link: "/adam_ig_datasets/history", text: "CDISC ADaM IG Datasets", icon: "icon-sdtm"},
    managed_collections: {link: "/managed_collections", text: "Managed Collections", icon: "icon-collection"},
    user_settings: {link: "/user_settings", text: "User Settings"},
    users: {link: "/users", text: "Users"},
    studies: {link: "/studies", text: "Studies", icon: "icon-study"},
    triples: {link: "#", text: "Triples", icon: "icon-triple"},
    items_generic: {link: "#", text: "Items", icon: "icon-multi"}
  }

  def instance_title(title, item)
    identifier = item.respond_to?(:scoped_identifier) ? item.scoped_identifier : item.identifier
    status = item.respond_to?(:registration_status) ? item.registration_status : item.registrationStatus
		return raw("#{title} #{item.label} <span class='text-tiny'>#{identifier} (V#{item.semantic_version}, #{item.version}, #{status})</span>")
	end

	# Bootstrap Class
  #
  # @param flash_type [String] the flash type
  # @return [String] the bootstrap class required
	def bootstrap_class_for(flash_type)
	  case flash_type
	    when "success"
	      "alert-success"   # Green
	    when "error"
	      "alert-danger"    # Red
	    when "alert"
	      "alert-warning"   # Yellow
	    when "notice"
	      "alert-info"      # Blue
	    else
	      flash_type.to_s
	  end
	end

	def link_group_on_role(klasses)
		klasses.each { |klass| return true if policy(klass).index? }
		return false
	end

	# Difference Glyphicon
  #
  # @param data [Hash] the data
  # @return [String] contains the HTML for the setting
	def diff_glyphicon(data)
		if data[:status] == :no_change
			return raw("<td class=\"text-center\"><span class=\"glyphicon glyphicon-arrow-down text-success\"/></td>")
		else
			return raw("<td>#{data[:difference]}</td>")
		end
	end

	# True/False Glyphicon in Table Cell
  #
  # @deprecated Use {#true_false_cell} instead of this method as it includes alignment flexibility
  # @param [Boolean] data the desired setting
  # @return [String] contains the HTML for the setting
  def true_false_glyphicon(data)
		true_false_cell(data, :center)
	end

  # True/False Cell
  #
  # @param [Boolean] data the desired setting
  # @param [Symbol] alignment the desired alignment, either :left, :right or :center
  # @return [String] returns the HTML for the setting
  def true_false_cell(data, alignment)
    span_class = "icon-" # Note space at end
    span_class += data ? "sel-filled text-link" : "times-circle text-accent-2"
    return raw("<td class=\"text-#{alignment}\"><span class=\"text-normal #{span_class}\"/></td>")
  end
  
  # Defines the MDR Menu categories and titles
  #
  # @return [Hash] MDR menu categories map  
  def mdr_categories
    {
      dashboard: "Dashboard",
      sysadmin: "System Admin",
      impexp: "Import/Export",
      util: "Utilities",
      term: "Terminology",
      biocon: "Biomedical Concepts",
      forms: "Forms",
      sdtm: "SDTM",
      adam: "ADaM",
    }
  end

  # Defines the SWB Menu categories and titles
  #
  # @return [Hash] SWB menu categories map  
  def swb_categories
    {
      studies: "Studies"
    }
  end

  # Get the sidebar cookie value to determine the saved collapsed state 
  #
  # @return [Boolean] True if sidebar state in cookie set to collapsed
  def sidebar_collapsed? 
    return cookies[:sidebar] == "false"
  end

  # Converts current controller reference to a string representing the menu parent under which it belongs
  #
  # @return [String] Parent menu category title of the currently active controller 
	def controller_to_menu

		controller_map = {
			dashboard: mdr_categories[:dashboard],
			iso_namespaces: mdr_categories[:sysadmin], iso_registration_authorities: mdr_categories[:sysadmin],	iso_managed: mdr_categories[:sysadmin], tokens: mdr_categories[:sysadmin], audit_trail: mdr_categories[:sysadmin],
			uploads: mdr_categories[:impexp], imports: mdr_categories[:impexp], exports: mdr_categories[:impexp], backgrounds: mdr_categories[:impexp],
			ad_hoc_reports: mdr_categories[:util], iso_concept_systems: mdr_categories[:util], markdown_engines: mdr_categories[:util],
			thesauri: mdr_categories[:term], cdisc_terms: mdr_categories[:term], managed_concepts: mdr_categories[:term],
			biomedical_concept_templates: mdr_categories[:biocon], biomedical_concept_instances: mdr_categories[:biocon],
			forms: mdr_categories[:forms],
			sdtm_models: mdr_categories[:sdtm], sdtm_igs: mdr_categories[:sdtm], sdtm_ig_domains: mdr_categories[:sdtm], sdtm_sponsor_domains: mdr_categories[:sdtm], sdtm_classes: mdr_categories[:sdtm],
      adam_igs: mdr_categories[:adam], adam_ig_datasets: mdr_categories[:adam],
      
      studies: swb_categories[:studies]
		}

		controller_map[controller_name.to_sym]
  end

  # Check whether menu category is currently selected (active) 
  #
  # @param [Symbol] category to check 
  # @return [Boolean] true if category is active
  def category_active(category)
    return false if controller_to_menu.nil?
    return controller_to_menu == mdr_categories[category] || controller_to_menu == swb_categories[category]
  end

  # Get menu category title
  #
  # @param [Symbol] category to get the title for 
  # @return [String] category title 
  def category_title(category) 
    mdr_categories[category] || swb_categories[category]
  end

  # Check if current Menu item is a part of the SWB menu map 
  #
  # @return [Boolean] True if current controller belongs to SWB menu map  
  def is_swb_menu?
    swb_categories.has_value? controller_to_menu
  end

  def get_iso_managed_icon(item)
    case item.rdf_type.to_s.downcase
    when /thesaur/
      "icon-terminology"
    when /form/
      "icon-forms"
    when /biomed/
      "icon-biocon"
    when /adam/
      "icon-adam"
    when /sdtm/
      "icon-sdtm"
    else
      item.label[0].upcase
    end
  end

  def id_to_type(id)
    type = @@id_to_type_map[id]
  end

  def user_policy_dashboard_panels
    user_role_panel_list = {}

    APP_CONFIG['dashboard_panels'].each do |key, value|
      case key
      when "terminologies"
        user_role_panel_list[key] = {name: value, url: "thesauri", safe_param: "thesauri"} if policy(Thesaurus).index?
      when "stats"
        user_role_panel_list[key] = {name: value, url: "", safe_param: ""} if current_user.has_role?(:sys_admin)
      # when "bct"
      #   user_role_panel_list[key] = {name: value, url: "biomedical_concept_templates", safe_param: "biomedical_concept_template"} if policy(BiomedicalConceptTemplate).index?
      # when "bcs"
      #   user_role_panel_list[key] = {name: value, url: "biomedical_concepts", safe_param: "biomedical_concept"} if policy(BiomedicalConceptInstance).index?
      # when "forms"
      #   user_role_panel_list[key] = {name: value, url: "forms", safe_param: ""} if policy(Form).index?
      # when "domains"
      #   user_role_panel_list[key] = {name: value, url: "sdtm_user_domains", safe_param: ""} if policy(SdtmUserDomain).index?
      end
    end
    user_role_panel_list
  end

  def item_accent_color (owner_name)
    if owner_name.upcase.include? "CDISC"
      return "bg-accent-1"
    else
      return "bg-prim-light"
    end
  end

  def item_accent_text_color (owner_name)
    if owner_name.upcase.include? "CDISC"
      return "text-accent-1"
    else
      return "text-link"
    end
  end

end
