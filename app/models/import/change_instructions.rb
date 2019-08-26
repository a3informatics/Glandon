# Import Rectangular. Import a rectangular excel structure
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::ChangeInstructions < Import

  @changes = []

  # Import. Import the change instructions
  #
  # @param [Hash] params a parameter hash
  # @option params [URI] :previous_ct
  # @option params [URI] :current_cy
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    previous_ct = Thesaurus.find_minimum(params[:previous_ct])
    current_ct = Thesaurus.find_minimum(params[:current_ct])
    read_all_excel(params)
    objects = self.errors.empty? ? process_changes(previous_ct, current_ct) : [self]
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of CDISC Change Instructions",
      parent_klass: ChangeInstruction,
      import_type: :cdisc_change_instructions
    }
  end
  
  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    self.class.configuration
  end

  class ChangeInstruction

    attr_accessor previous_parent
    attr_accessor previous_children
    attr_accessor current_parent
    attr_accessor current_children

    def initialize
      previous_parent = []
      previous_children = []
      current_parent = []
      current_children = []
    end

    def previous
      results = []
      previous_parent.each do |p|
        if previous_children.empty?
          results << [p]
        else
          previous_children.each do |c|
            results << [p, c]
          end
        end
      end
    end

    def current
      results = []
      current_parent.each do |p|
        if current_children.empty?
          results << [p]
        else
          current_children.each do |c|
            results << [p, c]
          end
        end
      end
    end

    def valid?
      return false if previous_children.count == 0 && current_children.count > 0 
      return false if previous_children.count > 0 && current_children.count == 0 
      return false if previous_children.count > 1 && current_parent.count > 1
      return true
    end

  end

private

  # Read all the Excel files
  def read_all_excel(params)
    params[:files].each do |file|
      reader = configuration[:reader_klass].new(file)
      merge_errors(reader, self)
      next if !reader.errors.empty?
      reader.check_and_process_sheet(configuration[:import_type], self.send(configuration[:sheet_name], params))
      merge_errors(reader, self)
      next if !reader.errors.empty?
      @changes = @changes + reader.engine.parent_set
    end
  end

  # Process all the changes
  def process_changes(previous_ct, current_ct)
    results = []
    @changes.each do |change|
      ci = CrossReference::ChangeInstruction.new
      change.previous.each {|p| ci.add_previous(previous_ct, x)}
      change.current.each {|p| ci.add_current(current_ct, x)}
      results << ci
    end
  end

  # def process_cdisc_term_changes_import(params, results)
  #   ordinals = {}
  #   uri = UriV2.new(uri: params[:uri])
  #   current_ct = CdiscTerm.find(uri.id, uri.namespace)
  #   previous = CdiscTerm.all_previous(current_ct.version)
  #   previous_ct = previous.last
  #   sparql = SparqlUpdateV2.new
  #   results.each do |result|
  #     result[:new_cl].each do |cl|
  #       sources = []
  #       parent = find_terminology({identifier: cl}, current_ct)
  #       if !parent.nil?
  #         if result[:new_cli].empty?
  #           sources << parent
  #         else
  #           result[:new_cli].each do |cli|
  #             child = find_terminology_child(parent, cli)
  #             if !child.nil?
  #               sources << child if !child.nil?
  #             else
  #               report_general_error("Failed to find child terminology item [1] with identifier: #{cli}")
  #               return
  #             end
  #           end
  #         end     
  #         sources.each do |source|
  #           ordinal = 1
  #           cr = CrossReference.new
  #           cr.comments = result[:instructions]
  #           cr.ordinal = get_ordinal(source, ordinals)
  #           previous = find_terminology({identifier: result[:previous_cl]}, previous_ct)
  #           if !previous.nil? 
  #             if result[:previous_cli].empty?
  #               cr.children << create_operational_ref(previous, source, ordinal)
  #             else
  #               result[:previous_cli].each do |cli|
  #                 child = find_terminology_child(previous, cli)
  #               if !child.nil?
  #                   cr.children << create_operational_ref(child, source, ordinal)
  #                   ordinal += 1
  #                 else
  #                   report_general_error("Failed to child find terminology item [2] with identifier: #{cli}")
  #                   return
  #                 end
  #               end
  #             end 
  #             ref_uri = cr.to_sparql_v2(source.uri, sparql)
  #             sparql.triple({uri: source.uri}, {:prefix => UriManagement::C_BCR, :id => "crossReference"}, {:uri => ref_uri})
  #           else
  #             report_general_error("Failed to find terminology item [3] with identifier: #{result[:previous_cl]}")
  #             return
  #           end
  #         end
  #       else
  #         report_general_error("Failed to find terminology item [4] with identifier: #{cl}")
  #         return
  #       end
  #     end
  #   end     
  #   load_sparql(sparql, "CDISC_CT_Instructions_V#{current_ct.version}.txt") 
  # end

end