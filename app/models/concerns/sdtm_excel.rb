require "roo"

module SdtmExcel

  # Constants
  C_CLASS_NAME = "SdtmExcel"

  # Role processing. Key word to identify the role
  C_ROLE_IDENTIFIER = "Identifier"
  C_ROLE_TOPIC = "Topic"
  C_ROLE_TIMING = "Timing"
  C_ROLE_RULE = "Rule"
  C_ROLE_GROUPING = "Grouping"
  C_ROLE_RESULT = "Result"
  C_ROLE_SYNONYM = "Synonym"
  C_ROLE_RECORD = "Record"
  C_ROLE_VARIABLE = "Variable"
  C_ROLE_NONE = "None"   
  C_ROLE = 
  {
    C_ROLE_IDENTIFIER => { :classification => SdtmModel::Variable::C_ROLE_IDENTIFIER, :sub_classification => SdtmModel::Variable::C_ROLE_Q_NA } ,
    C_ROLE_TOPIC => { :classification => SdtmModel::Variable::C_ROLE_TOPIC , :sub_classification => SdtmModel::Variable::C_ROLE_Q_NA } ,
    C_ROLE_TIMING => { :classification => SdtmModel::Variable::C_ROLE_TIMING , :sub_classification => SdtmModel::Variable::C_ROLE_Q_NA } ,
    C_ROLE_RULE => { :classification => SdtmModel::Variable::C_ROLE_RULE , :sub_classification => SdtmModel::Variable::C_ROLE_Q_NA } ,
    C_ROLE_GROUPING => { :classification => SdtmModel::Variable::C_ROLE_QUALIFIER , :sub_classification => SdtmModel::Variable::C_ROLE_Q_GROUPING } ,
    C_ROLE_RESULT => { :classification => SdtmModel::Variable::C_ROLE_QUALIFIER , :sub_classification => SdtmModel::Variable::C_ROLE_Q_RESULT } ,
    C_ROLE_SYNONYM => { :classification => SdtmModel::Variable::C_ROLE_QUALIFIER , :sub_classification => SdtmModel::Variable::C_ROLE_Q_SYNONYM } ,
    C_ROLE_RECORD  => { :classification => SdtmModel::Variable::C_ROLE_QUALIFIER , :sub_classification => SdtmModel::Variable::C_ROLE_Q_RECORD } ,
    C_ROLE_VARIABLE => { :classification => SdtmModel::Variable::C_ROLE_QUALIFIER , :sub_classification => SdtmModel::Variable::C_ROLE_Q_VARIABLE } ,
    C_ROLE_NONE => { :classification => SdtmModel::Variable::C_ROLE_NONE , :sub_classification => SdtmModel::Variable::C_ROLE_Q_NA }
  }

  # Core processing. Key word to indentify the role
  C_CORE_R = "Req"
  C_CORE_E = "Exp"
  C_CORE_P = "Perm"
  C_CORE = 
  {
    C_CORE_R => SdtmIgDomain::Variable::C_CORE_REQD,
    C_CORE_E => SdtmIgDomain::Variable::C_CORE_EXP,
    C_CORE_P => SdtmIgDomain::Variable::C_CORE_PERM
  }

  # SDTM Class string defintions used across the various versions. Maps to common model.
  C_ALL = "ALL"
  C_E = SdtmModelDomain::C_EVENTS_LABEL
  C_I = SdtmModelDomain::C_INTERVENTIONS_LABEL
  C_F = SdtmModelDomain::C_FINDINGS_LABEL
  C_FA = SdtmModelDomain::C_FINDINGS_ABOUT_LABEL
  C_SP = SdtmModelDomain::C_SPECIAL_PURPOSE_LABEL
  C_TD = SdtmModelDomain::C_TRIAL_DESIGN_LABEL
  C_R = SdtmModelDomain::C_RELATIONSHIP_LABEL
  C_AP = SdtmModelDomain::C_ASSOCIATED_PERSON_LABEL
  C_SDTM_MODEL_CLASS = 
  { 
    "All Classes" => C_ALL, 
    "Events" => C_E, 
    "Events-General" => C_E, 
    "Interventions" => C_I, 
    "Interventions-General" => C_I, 
    "Special Purpose" => C_SP, 
    "Special-Purpose" => C_SP, 
    "Findings" => C_F, 
    "Findings-General" => C_F, 
    "Findings About" => C_FA, 
    "Findings About-General" => C_FA,
    "Relationship" => C_R, 
    "Trial Design" => C_TD, 
    "Associated Persons" => C_AP, 
  }

  C_MAIN_CHECK_KEY = "Seq. For Order"
  C_EXTRA_CHECK_KEY = "Domain Prefix"
  C_DOMAIN_IGNORE = {"TX" => true, "POOLDEF" => true, "RELSUB" => true, "APRELSUB" => true}

  # Reads the excel file for SDTM Model.
  def SdtmExcel.read_model (params, errors)
    filename = params[:files][0]
    workbook = open_workbook(filename)
    if !workbook.nil?
      # Get the worksheets
      worksheets = workbook.sheets
      # Set up structures needed
      identifiers = Array.new
      timing = Array.new
      events = Array.new
      interventions = Array.new
      findings = Array.new
      findings_about = Array.new
      associated_persons = Array.new
      special_purpose = Array.new
      trial_design = Array.new
      relationship = Array.new
      variables = Array.new
      # Set up results structure
      results = Array.new
      # Create the instance for the model
      instance = create_model(params, SdtmModel::C_IDENTIFIER, "SDTM Model #{params[:date]}")
      instance[:ordinal] = 1
      results << { :type => "MODEL", :order => 1, :instance => instance}
      # Set the main workbook and check it. Return if errors.
      workbook.default_sheet = workbook.sheets[0]
      check_main(workbook, errors)
      if errors.count != 0 
        return
      end
      # All ok. Read the rows.
      #ConsoleLogger::log(C_CLASS_NAME,"read_model","Read rows, First=#{workbook.first_row}, Last=#{workbook.last_row}.")
      ((workbook.first_row + 1) .. workbook.last_row).each do |row|
        domain_prefix = workbook.cell(row, 3)
        if domain_prefix.blank?
          seq = check_cell(workbook, row, 1, errors)
          obs_class = check_cell(workbook, row, 2, errors)            
          name_minus = check_cell(workbook, row, 4, errors)
          name = check_cell(workbook, row, 5, errors)
          label = check_cell(workbook, row, 6, errors)
          var_type = check_cell(workbook, row, 7, errors)
          ct_or_format = "" # We dont care.
          role = check_cell(workbook, row, 9, errors)
          notes = check_cell(workbook, row, 10, errors, true)
          core = "" # We dont care.
          if errors.count > 0 
            return
          end
          # SDTM Model Processing
          if C_SDTM_MODEL_CLASS.has_key?(obs_class)
            role_hash = set_role(role)
            if role_hash.nil?
              errors.add(:base, "Invalid role detected #{role} in row #{row}")
              return
            else   
              obs_class_key = C_SDTM_MODEL_CLASS[obs_class]
              if obs_class_key == C_ALL
                if role_hash[:classification] == SdtmModel::Variable::C_ROLE_IDENTIFIER
                  target = identifiers
                elsif role_hash[:classification] == SdtmModel::Variable::C_ROLE_TIMING
                  target = timing
                else
                  errors.add(:base, "Invalid role and class combination detected #{role} for #{obs_class} in row #{row}.")
                  return
                end
              elsif obs_class_key == C_E
                target = events 
              elsif obs_class_key == C_F
                target = findings 
              elsif obs_class_key == C_I
                target = interventions
              elsif obs_class_key == C_AP
                target = interventions
              elsif obs_class_key == C_FA
                target = findings_about
              elsif obs_class_key == C_SP
                target = special_purpose
              elsif obs_class_key == C_TD
                target = trial_design
              elsif obs_class_key == C_R
                target = relationship
              else
                errors.add(:base, "Invalid observation class detected #{obs_class} in row #{row}. Inconsistent logic.")
                return 
              end
              variable = SdtmModel::Variable.new
              variable.ordinal = seq 
              variable.label = label
              variable.name = name
              variable.datatype = SdtmModelDatatype.new 
              variable.datatype.label = var_type
              variable.classification = SdtmModelClassification.new
              variable.classification.label = role_hash[:classification]
              variable.sub_classification = SdtmModelClassification.new
              variable.sub_classification.label = role_hash[:sub_classification]
              variable.prefixed = SdtmUtility.prefixed?(name)
              variable.description = notes
              variables << variable.to_json
              target << 
              {
                :ordinal => seq, 
                :variable_name => name, 
                :label => label
              }
            end
          else
            errors.add(:base, "Invalid observation class detected #{obs_class} in row #{row}")
            return 
          end
        end
      end
      # Make sure sorted by sequence number
      identifiers.sort_by { |k, v| k[:ordinal] }
      timing.sort_by { |k, v| k[:ordinal] }
      events.sort_by { |k, v| k[:ordinal] }
      findings.sort_by { |k, v| k[:ordinal] }
      interventions.sort_by { |k, v| k[:ordinal] }
      # Create the model class/domain instances.
      # @todo Other classes to be done.
      child_instance = create_model_class([identifiers, events, timing], SdtmModelDomain::C_EVENTS_IDENTIFIER, 
      	SdtmModelDomain::C_EVENTS_LABEL, instance)    
      results << { :type => "MODEL_DOMAIN", :order=> 2, :instance => child_instance}
      child_instance = create_model_class([identifiers, interventions, timing], SdtmModelDomain::C_INTERVENTIONS_IDENTIFIER, 
      	SdtmModelDomain::C_INTERVENTIONS_LABEL, instance)    
      results << { :type => "MODEL_DOMAIN", :order => 2, :instance => child_instance}
      child_instance = create_model_class([identifiers, findings, timing], SdtmModelDomain::C_FINDINGS_IDENTIFIER, 
      	SdtmModelDomain::C_FINDINGS_LABEL, instance) 
      results << { :type => "MODEL_DOMAIN", :order=> 2, :instance => child_instance}
      child_instance = create_model_class([identifiers, special_purpose, timing], SdtmModelDomain::C_SPECIAL_PURPOSE_IDENTIFIER, 
      	SdtmModelDomain::C_SPECIAL_PURPOSE_LABEL, instance) 
      results << { :type => "MODEL_DOMAIN", :order=> 2, :instance => child_instance}
      child_instance = create_model_class([identifiers, trial_design, timing], SdtmModelDomain::C_TRIAL_DESIGN_IDENTIFIER, 
      	SdtmModelDomain::C_TRIAL_DESIGN_LABEL, instance) 
      results << { :type => "MODEL_DOMAIN", :order=> 2, :instance => child_instance}
      child_instance = create_model_class([identifiers, relationship], SdtmModelDomain::C_RELATIONSHIP_IDENTIFIER, 
      	SdtmModelDomain::C_RELATIONSHIP_LABEL, instance) 
      results << { :type => "MODEL_DOMAIN", :order=> 2, :instance => child_instance}
      # Add the variables for the model
      managed_item = instance[:managed_item]
      children = managed_item[:children]
      variables.each do |variable|
        children[children.length] = variable
      end
    else
      errors.add(:base, "Could not open the import file.")
      return 
    end
    results.sort{|k,v| v[:order]}
    #ConsoleLogger::log(C_CLASS_NAME,"read_model","Results=" + results.to_json.to_s)
    return results
  end

  # Reads the excel file for SDTM IG.
  def SdtmExcel.read_ig (params, errors)
    filename = params[:files][0]
    #ConsoleLogger::log(C_CLASS_NAME,"read_ig", "filename=#{filename}")
    workbook = open_workbook(filename)
    if !workbook.nil?
        # Get the worksheet, assume first sheet.
        worksheets = workbook.sheets
        # Set up structures needed
        domains = Hash.new
        # Set up results structure
        results = Array.new
        # Create the instance for the IG itself
        instance = create_model(params, SdtmIg::C_IDENTIFIER, "SDTM Implementation Guide #{params[:date]}")
        results << { :type => "IG", :order=> 1, :instance => instance}
        # Setup the domains from the Extra sheet.
        select_extra(workbook, errors)
        if errors.count > 0
            return 
        end
        check_extra(workbook, errors)
        if errors.count > 0 
            return
        end
        ((workbook.first_row + 1) .. workbook.last_row).each do |row|
            # obs_class = workbook.row(row)[headers['Observation Class']]
            domain_prefix = workbook.cell(row, 1)
            label = workbook.cell(row, 2)
            structure = workbook.cell(row, 3)
            domains[domain_prefix] = {:prefix => domain_prefix, :label => label, :structure => structure, :children => Array.new}
        end
        # Set the main worksheet and check it. Return if errors.
        workbook.default_sheet = workbook.sheets[0]
        check_main(workbook, errors)
        if errors.count > 0 
            return
        end
        # All ok, Read the rows.
        ((workbook.first_row + 1) .. workbook.last_row).each do |row|
            domain_prefix = workbook.cell(row, 3)
            if !domain_prefix.blank?
                if !C_DOMAIN_IGNORE.has_key?(domain_prefix)
                    seq = check_cell(workbook, row, 1, errors)
                    obs_class = check_cell(workbook, row, 2, errors)            
                    name_minus = check_cell(workbook, row, 4, errors)
                    name = check_cell(workbook, row, 5, errors)
                    label = check_cell(workbook, row, 6, errors)
                    var_type = check_cell(workbook, row, 7, errors)
                    ct_or_format = check_cell(workbook, row, 8, errors, true)
                    #ct_or_format = ct_or_format_read.gsub(/[^A-Za-z0-9 ]/, '')
                    #if ct_or_format_read != ct_or_format
                    #    ConsoleLogger::log(C_CLASS_NAME,"read_ig","CT modified: #{ct_or_format_read} -> #{ct_or_format}.")
                    #end
                    role = check_cell(workbook, row, 9, errors, true)
                    if role.empty?
                        role = C_ROLE_NONE
                    end
                    notes = check_cell(workbook, row, 10, errors, true)
                    core = check_cell(workbook, row, 11, errors, true)
                    # SDTM IG Processing
                    if C_SDTM_MODEL_CLASS.has_key?(obs_class)
                        role_hash = set_role(role)
                        if domains.has_key?(domain_prefix)
                            domain = domains[domain_prefix]
                            domain[:children] << 
                                {
                                    :ordinal => seq, 
                                    :label => label, 
                                    :variable_class => C_SDTM_MODEL_CLASS[obs_class], #obs_class, 
                                    :variable_domain_prefix => domain_prefix, 
                                    :variable_name => name, 
                                    :variable_name_minus => name_minus, 
                                    :variable_type => var_type, 
                                    :variable_ct_or_format => ct_or_format, 
                                    :variable_classification => role_hash[:classification], 
                                    :variable_sub_classification => role_hash[:sub_classification],
                                    :variable_prefixed => SdtmUtility.prefixed?(name), 
                                    :variable_notes => notes, 
                                    :variable_core => C_CORE[core]
                                }
                        end
                    else
                        errors.add(:base, "Invalid observation class detected #{obs_class} in row #{row}")
                        return 
                    end
                else
                    #ConsoleLogger::log(C_CLASS_NAME,"read_ig","Ignoring entry for domain #{domain_prefix}.")
                end
            end
        end
    else
        errors.add(:base, "Could not open the import file.")
        return 
    end
    domains.each do |key, domain|
        if domain[:children].length > 0
            child_instance = create_ig_domain(domain, instance)    
            results << { :type => "IG_DOMAIN", :order=> 2, :instance => child_instance}
        end
    end
    results.sort{|k,v| v[:order]}
    #ConsoleLogger::log(C_CLASS_NAME,"read_ig","Results=" + results.to_json.to_s)
    return results
  end

private

  def self.open_workbook(filename)
    workbook = Roo::Spreadsheet.open(filename, extension: :xlsx) 
  rescue => e
    #ConsoleLogger::log(C_CLASS_NAME,"open_workbook","e=#{e.to_s}, filename=#{filename}.")
    workbook = nil
  end

  def self.select_extra(workbook, errors)
    workbook.default_sheet = 'Extra'
  rescue => e
    errors.add(:base, "Missing 'Extra' sheet in the excel file.")
  end

  def self.check_cell(workbook, row, col, errors, allow_blank=false)
    value = workbook.cell(row, col)
    if value.blank? and allow_blank
        value = ""
    elsif value.blank?
        errors.add(:base, "Empty cell detected in row #{row}, column #{col}.")
    end
    # Return value as string, strip leading and trailing spaces.
    return "#{value}".strip
  end
              
  def self.check_main(workbook, errors)
    # 1. Seq. For Order  
    # 2. Observation Class 
    # 3. Domain Prefix 
    # 4. Variable Name (minus domain prefix) 
    # 5. Variable Name 
    # 6. Variable Label  
    # 7. Type  
    # 8. Controlled Terms or Format  
    # 9. Role  
    # 10. CDISC Notes (for domains) Description (for General Classes) 
    # 11. Core
    if workbook.nil?
        errors.add(:base, "Missing Main sheet in the excel file.")
        return 
    end
    headers = Hash.new
    workbook.row(1).each_with_index do |header, i|
        headers[header] = i
    end
    #ConsoleLogger::log(C_CLASS_NAME,"check_main","Headers=#{headers.to_json}")
    if headers.length != 11
        errors.add(:base, "Main sheet in the excel file, incorrect column count, indicates format error.")
        return 
    end
    if !headers.has_key?(C_MAIN_CHECK_KEY) 
        errors.add(:base, "Main sheet in the excel file, incorrect 1st column name, indicates format error.")
        return 
    end 
  rescue => e
    errors.add(:base, "Unexpected exception. Possibly an empty Main sheet.")
  end

  def self.check_extra(workbook, errors)
    # 1. Domain Prefix
    # 2. Domain Name 
    # 3. Structure 
    if workbook.nil?
      errors.add(:base, "Missing Extra sheet in the excel file.")
      return 
    end
    headers = Hash.new
    workbook.row(1).each_with_index do |header, i|
      headers[header] = i
    end
    #ConsoleLogger::log(C_CLASS_NAME,"check_extra","Headers=#{headers.to_json}")
    if headers.length != 3
      errors.add(:base, "Extra sheet in the excel file, incorrect column count, indicates format error.")
      return 
    end
    if !headers.has_key?(C_EXTRA_CHECK_KEY) 
      errors.add(:base, "Extra sheet in the excel file, incorrect 1st column name, indicates format error.")
      return 
    end 
  rescue => e
     errors.add(:base, "Unexpected exception. Possibly an empty Extra sheet.")
  end

  def self.create_model(params, identifier, label)
  	# Create the instance for the model
    object = SdtmModel.new
    object.label = label
    object.scopedIdentifier.identifier = identifier
    object.scopedIdentifier.versionLabel = params[:version_label]
    # Build the full object
    operation = object.to_operation
    operation[:operation][:new_version] = params[:version]
    operation[:operation][:new_state] = IsoRegistrationState.releasedState
		operation[:managed_item][:creation_date] = params[:date]
		return operation
  end        

  def self.create_model_class (variable_set, identifier, label, model_instance)
     # Create the instance for the model
    object = SdtmModelDomain.new
    object.label = label
    object.scopedIdentifier.identifier = identifier
    object.scopedIdentifier.versionLabel = model_instance[:managed_item][:scoped_identifier][:version_label]
    # Build the full object
    operation = object.to_operation
    operation[:operation][:new_version] = model_instance[:operation][:new_version]
    operation[:operation][:new_state] = IsoRegistrationState.releasedState
		operation[:managed_item][:creation_date] = model_instance[:managed_item][:creation_date]
    domain_mi = operation[:managed_item]
    children = domain_mi[:children]
    # Add the children for each group of variables within the set
    ordinal = 1
    variable_set.each do |set|
      set.each do |variable|
        #role = variable[:role]
        children <<
        {
          :ordinal => ordinal, 
          :label => variable[:label], 
          :variable_name => variable[:variable_name], 
        }
        ordinal += 1
      end
    end
    return operation
  end        
  
  def self.create_ig_domain(domain, ig_instance)
    ig_mi = ig_instance[:managed_item]
    item = IsoManaged.new
    instance = item.to_operation
    domain_mi = instance[:managed_item]
    domain_op = instance[:operation]
    domain_mi[:identifier] = "SDTM IG #{domain[:prefix]}"
    domain_mi[:version] = ig_mi[:version]
    domain_mi[:creation_date] = ig_mi[:creation_date]
    domain_mi[:last_changed_date] = ig_mi[:last_changed_date]
    domain_mi[:version_label] = ig_mi[:version_label]
    domain_mi[:label] = domain[:label]
    domain_mi[:prefix] = domain[:prefix]
    domain_mi[:structure] = domain[:structure]
    domain_mi[:domain_class] = domain[:children][0][:variable_class]
    domain_op[:new_version] = domain_mi[:version] # Make sure this is set. Sets the right version.
    children = domain_mi[:children]
    # Add the children for each group of variables within the set
    ordinal = 1
    domain[:children].sort_by { |k, v| k[:seq] }
    domain[:children].each do |variable|
      children << variable
      ordinal += 1
    end
    return instance
  end        
  
  def self.set_role(role)
    result = nil
    words = role.split(/\W+/)
    if C_ROLE.has_key?(words[0])
      result = C_ROLE[words[0]]
    end
    return result
  end

end

    