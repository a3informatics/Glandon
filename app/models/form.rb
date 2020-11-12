# require 'odm'
class Form < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Form",
            uri_suffix: "F"

  data_property :note
  data_property :completion

  object_property :has_group, cardinality: :many, model_class: "Form::Group::Normal", children: true

  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?

  include Form::Ordinal

  def clone
    self.has_group_links
    super
  end

  # Clone the item and create. Use Sparql approach in case of children also need creating
  #   so we need to recruse. Also generate URI for this object and any children to ensure we catch the children.
  #   The Children are normally references. Also note the setting of the transaction in the cloned object and
  #   in the sparql generation, important both are done.
  def clone_children_and_save(tx, uri = nil)
    sparql = Sparql::Update.new(tx)
    new_object = nil
    set = self.has_group
    set.each do |child|
      object = child.clone
      object.transaction_set(tx)
      object.generate_uri(self.uri)
      object.to_sparql(sparql, true)
      self.replace_link(child.managed_ancestors_predicate, child.uri, object.uri)
      unless uri.nil?
        new_object = object if child.uri == uri
      end
    end
    sparql.create
    new_object
  end

  def move_up_with_clone(child, managed_ancestor)
    if child.multiple_managed_ancestors?
      parent_and_child = clone_nodes(child, managed_ancestor)
      parent_and_child.first.move_up(parent_and_child.second)
    else
      move_up(child)
    end
  end

  def move_down_with_clone(child, managed_ancestor)
    if child.multiple_managed_ancestors?
      parent_and_child = clone_nodes(child, managed_ancestor)
      parent_and_child.first.move_down(parent_and_child.second)
    else
      move_down(child)
    end
  end

  def clone_nodes(child, managed_ancestor)
    new_parent = nil
    new_object = nil
    tx = transaction_begin
    managed_ancestor.transaction_set(tx)
    new_object = managed_ancestor.clone_children_and_save(tx, child.uri)
    transaction_execute
    new_parent = Form.find_full(managed_ancestor.id)
    return new_parent, new_object
  end

  # Get Items.
  #
  # @return [Array] Array of hashes, one per group, sub group and item. Ordered by ordinal.
  def get_items
    results = []
    form = self.class.find_full(self.uri)
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      results += group.get_item
    end
    return results
  end

  # To CRF.
  #
  # @return [String] String of HTML form representation
  def to_crf
    form = self.class.find_full(self.uri)
    html = ''
    html += get_css
    html += '<table class="table table-striped table-bordered table-condensed" id="crf">'
    html += '<tr>'
    html += '<td colspan="2"><h4>' + form.label + '</h4></td>'
    html += '</tr>'
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      html += group.to_crf
    end
    html += '</table>'
  end

  # Get Referenced Items.
  #
  # @return [Hash] key: reference ID, value: item
  def get_referenced_items
    items = []
    results = {}
    form = self.class.find_full(self.uri)
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      items += group.get_item
    end
    items = items.each do |item|
      item[:has_coded_value].each do |cv|
        results[cv[:id]] = cv[:reference]
      end
      results[item[:has_biomedical_concept][:id]] = item[:has_biomedical_concept][:reference] unless item[:has_biomedical_concept].nil?
      unless item[:has_common].nil? || item[:has_common].empty?
        item[:has_common].first[:has_item].each do |ci|
          ci[:has_coded_value].each do |cv|
            results[cv[:id]] = Thesaurus::UnmanagedConcept.find(Uri.new(uri:cv[:reference])).to_h
          end
        end
      end
    end
    return results
  end

  # Add child.
  #
  # @return
  def add_child(params)
    self.errors.add(:base, "Attempting to add an invalid child type") if params[:type].to_sym != :normal_group
    ordinal = next_ordinal(:has_group)
    child = Form::Group::Normal.create(label: "Not set", ordinal: ordinal, parent_uri: self.uri)
    return child if child.errors.any?
    self.add_link(:has_group, child.uri)
    child
  end

  def children_ordered
    self.has_group_objects.sort_by {|x| x.ordinal}
  end

  # Full data
  #
  # @return [Hash] Return the data of the whole Form, all its children + any referenced item data.
  def full_data
    form = self.to_h
    form[:has_group] = []
    self.has_group.sort_by {|x| x.ordinal}.each do |group|
      form[:has_group] << group.full_data
    end
    form
  end

  private

    # Next Ordinal. Get the next ordinal for a managed item collection
    #
    # @param [String] name the name of the property holding the collection
    # @return [Integer] the next ordinal
    def next_ordinal(name)
      predicate = self.properties.property(name).predicate
      query_string = %Q{
        SELECT (MAX(?ordinal) AS ?max)
        {
          #{self.uri.to_ref} #{predicate.to_ref} ?s .
          ?s bf:ordinal ?ordinal
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bf])
      return 1 if query_results.empty?
      query_results.by_object(:max).first.to_i + 1
    end

    def get_css
      html = "<style>"
      html += "table.crf-input-field { border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;}\n"
      html += "table.crf-input-field tr td { font-family: Arial, \"Helvetica Neue\", Helvetica, sans-serif; font-size: 8pt; text-align: center; "
      html += "vertical-align: center; padding: 5px; }\n"
      html += "table.crf-input-field td:not(:last-child){border-right: 1px dashed}\n"
      html += "h4.domain-1 {border-radius: 5px; background: #A3E4D7; padding: 5px; }\n"
      html += "p.domain-1 {border-radius: 5px; background: #A3E4D7; padding: 5px; }\n"
      html += "h4.domain-2 {border-radius: 5px; background: #AED6F1; padding: 5px; }\n"
      html += "p.domain-2 {border-radius: 5px; background: #AED6F1; padding: 5px; }\n"
      html += "h4.domain-3 {border-radius: 5px; background: #D2B4DE; padding: 5px; }\n"
      html += "p.domain-3 {border-radius: 5px; background: #D2B4DE; padding: 5px; }\n"
      html += "h4.domain-4 {border-radius: 5px; background: #FAD7A0; padding: 5px; }\n"
      html += "p.domain-4 {border-radius: 5px; background: #FAD7A0; padding: 5px; }\n"
      html += "h4.domain-5 {border-radius: 5px; background: #F5B7B1; padding: 5px; }\n"
      html += "p.domain-5 {border-radius: 5px; background: #F5B7B1; padding: 5px; }\n"
      html += "h4.domain-other {border-radius: 5px; background: #BDC3C7; padding: 5px; }\n"
      html += "p.domain-other {border-radius: 5px; background: #BDC3C7; padding: 5px; }\n"
      html += "</style>"
    end

end
