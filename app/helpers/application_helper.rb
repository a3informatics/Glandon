module ApplicationHelper

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

	# Get Current Item
  #
  # @param items [Array] array of items one of which is the current item
  # @return [Object] the current item or nil if none
	def get_current_item(items)
	  current_set = items.select{|item| item.current?}
	  if current_set.length == 1
	  	return current_set[0]
	  else
	  	return nil
	  end
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
    span_class += data ? "ok text-secondary-clr" : "times text-accent-2"
    return raw("<td class=\"text-#{alignment}\"><span class=\"#{span_class}\"/></td>")
  end

	# Return the datatable settings for column ordering
  #
  # @return [String] contains settings for the column ordering
  def column_order(column, order)
    return "[[#{column}, 'asc']]" if order == :asc
    return "[[#{column}, 'desc']]" if order == :desc
    return "[[#{column}, 'asc']]"
  end

	# Close button that performs a browser back function
  #
  # @param [Text] the text for the button. Defaults to "Close"
  # @return [Null]
  def back_close_button(text="Close")
  	return raw("<a class=\"btn \" href=\"javascript:history.back()\">#{text}</a>")
  end

  # Top Level Breadcrumb
  #
  # @param text [String] the breadcrumb link text
  # @return [Null]
  def top_level_breadcrumb(text)
  	breadcrumb ([{link: "#", text: "#{text}"}])
  end

  # Second Level Breadcrumb
  #
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param text [String] the second-level breadcrumb link text
  # @return [Null]
  def second_level_breadcrumb(parent_text, parent_link, text)
  	breadcrumb ([{link: parent_link, text: "#{parent_text}"}, {link: "#", text: "#{text}"}])
  end

  # Third Level Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_text [String] the second-level breadcrumb link text
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  def third_level_breadcrumb(parent_text, parent_link, second_level_text, second_level_link, third_level_text)
    breadcrumb ([{link: parent_link, text: "#{parent_text}"},
      {link: second_level_link, text: "#{second_level_text}"},
      {link: "#", text: "#{third_level_text}"}])
  end

  # Third Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @return [Null]
  def third_level_managed_item_breadcrumb(managed_item, parent_text, parent_link, second_level_link, third_level_action)
    identifier = managed_item.respond_to?(:scoped_identifier) ? managed_item.scoped_identifier : managed_item.identifier
  	breadcrumb ([{link: parent_link, text: "#{parent_text}"},
  		{link: second_level_link, text: "#{identifier}"},
  		{link: "#", text: "#{third_level_action} V#{managed_item.semantic_version}"}])
  end

  # Fourth Level Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_text [String] the second-level breadcrumb link text
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  def fourth_level_breadcrumb(parent_text, parent_link, second_level_text, second_level_link, third_level_text, third_level_link, fourth_level_text)
    breadcrumb ([{link: parent_link, text: "#{parent_text}"},
      {link: second_level_link, text: "#{second_level_text}"},
      {link: third_level_link, text: "#{third_level_text}"},
      {link: "#", text: "#{fourth_level_text}"}])
  end

  # Fourth Level Managed-Item Breadcrumb
  #
  # @param managed_item [Object] the managed item
  # @param parent_text [String] the parent-level breadcrumb link text
  # @param parent_link [String] the parent-level link
  # @param second_level_link [String] the second-level link
  # @param third_level_action [String] the third-level prefix for the link text
  # @param third_level_link [String] the third-level link
  # @param fourth_level_text [String] the third-level link
  # @return [Null]
  def fourth_level_managed_item_breadcrumb(managed_item, parent_text, parent_link, second_level_link, third_level_action, third_level_link, fourth_level_text)
    breadcrumb ([{link: parent_link, text: "#{parent_text}"},
      {link: second_level_link, text: "#{managed_item.identifier}"},
      {link: third_level_link, text: "#{third_level_action} V#{managed_item.semantic_version}"},
      {link: "#", text: "#{fourth_level_text}"},
      ])
  end

  # Breadcrumb. Formats the HTML for the breadcrumb. Places into a session variable.
  #

  # @param items [Array] array of hash items holding the text and link for each level of the breadcrumb
  # @return [Null]
  def breadcrumb(items)
  	result = "<ol class=\"breadcrumb\">"
  	index = 1
  	items.each do |item|
  		result += item.equal?(items.last) ? "<li id=\"breadcrumb_#{index}\" class=\"active\">#{item[:text]}</li>" : "<li id=\"breadcrumb_#{index}\"><a href=\"#{item[:link]}\">#{item[:text]}</a></li>"
  		index += 1
  	end
  	result += "</ol>"
  	session[:breadcrumbs] = raw(result)
  end

	# Converts a controller reference to a string representing the menu parent under which it belongs
	def controller_to_menu

		@category_dashboard = "Dashboard"
		@category_sysadmin = "System Admin"
		@category_impexp = "Import/Export"
		@category_util = "Utilities"
		@category_term = "Terminology"
		@category_biocon = "Biomedical Concepts"
		@category_forms = "Forms"
		@category_sdtm = "SDTM"
		@category_adam = "ADaM"

		@controller_map = {
			dashboard: @category_dashboard,
			iso_namespaces: @category_sysadmin, iso_registration_authorities: @category_sysadmin,	iso_managed: @category_sysadmin, tokens: @category_sysadmin, audit_trail: @category_sysadmin,
			uploads: @category_impexp, imports: @category_impexp, exports: @category_impexp, backgrounds: @category_impexp,
			ad_hoc_reports: @category_util, iso_concept_systems: @category_util, markdown_engines: @category_util,
			thesauri: @category_term, cdisc_terms: @category_term,
			biomedical_concept_templates: @category_biocon, biomedical_concepts: @category_biocon,
			forms: @category_forms,
			sdtm_models: @category_sdtm, sdtm_igs: @category_sdtm, sdtm_user_domains: @category_sdtm,
			adam_igs: @category_adam
		}

		@controller_map[controller_name.to_sym]
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

  def thesaurus_accent_color (owner_name)
    if owner_name.upcase.include? "CDISC"
      return "bg-accent-1"
    else
      return "bg-prim-light"
    end
  end

end
