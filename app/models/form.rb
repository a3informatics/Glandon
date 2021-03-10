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
  include Form::CRF

  @@owner_ra = nil

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    return @@owner_ra if !@@owner_ra.nil?
    @@owner_ra = IsoRegistrationAuthority.owner
    @@owner_ra.freeze
  end

  # Children Ordered. Returns the set of children nodes ordered by ordinal. 
  #
  # @return [Form::Group::Normal] array of objects
  def children_ordered
    self.children_objects.sort_by {|x| x.ordinal}
  end

  # Clone. Clone the Form
  #
  # @return [Form] a clone of the object
  def clone
    self.has_group_links
    super
  end

  # aCRF.
  #
  # @return [String] String of HTML form representation with annotations
  def acrf
    annotations = Form::Annotations.new(self)
    to_crf(annotations)
  end

  # CRF.
  #
  # @return [String] String of HTML form representation
  def crf
    to_crf
  end

  # Move Up With Clone
  #
  # @param [Object] child the object to be moved
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Void] no return
  def move_up_with_clone(child, managed_ancestor)
    if child.multiple_managed_ancestors?
      parent_and_child = self.replicate_siblings_with_clone(child, managed_ancestor)
      parent_and_child.first.move_up(parent_and_child.second)
    else
      move_up(child)
    end
  end

  # Move Down With Clone
  #
  # @param [Object] child the object to be moved
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Void] no return
  def move_down_with_clone(child, managed_ancestor)
    if child.multiple_managed_ancestors?
      parent_and_child = self.replicate_siblings_with_clone(child, managed_ancestor)
      parent_and_child.first.move_down(parent_and_child.second)
    else
      move_down(child)
    end
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

  # Dependency Paths. Returns the paths for any dependencies this class may have.
  #
  # @return [Array] array of strings suitable for inclusion in a sparql query
  def self.dependency_paths
    [
      '<http://www.assero.co.uk/BusinessForm#hasGroup>/'\
      '<http://www.assero.co.uk/BusinessForm#hasSubGroup>*/'\
      '<http://www.assero.co.uk/BusinessForm#hasItem>/'\
      '<http://www.assero.co.uk/BusinessForm#hasCodedValue>/'\
      '<http://www.assero.co.uk/BusinessOperational#reference>/'\
      '^<http://www.assero.co.uk/Thesaurus#narrower>',

      '<http://www.assero.co.uk/BusinessForm#hasGroup>/'\
      '<http://www.assero.co.uk/BusinessForm#hasSubGroup>*/'\
      '<http://www.assero.co.uk/BusinessForm#hasBiomedicalConcept>/'\
      '<http://www.assero.co.uk/BusinessOperational#reference>'
    ]
  end

private
  
  # To CRF.
  #
  # @return [String] String of HTML form representation
  def to_crf(annotations = nil) 
    form = self.class.find_full(self.uri)
    html = ''
    html += get_css
    html += '<table class="table table-striped table-bordered table-condensed" id="crf">'
    html += '<tr>'
    html += '<td colspan="2"><h4>' + form.label + '</h4></td>'
    unless annotations.nil?
      html += '<td>' 
      domains = annotations.domain_list
      domains.each_with_index do |(prefix, hash_domain), index|
        domain_annotation = prefix.to_s
        if !hash_domain[:long_name].blank?
          domain_annotation += "=" + hash_domain[:long_name]
        end
        class_suffix = index < domain_count ? "#{index + 1}" : "other"
        class_name = "domain-#{class_suffix}"
        html += "<h4 class=\"#{class_name}\">#{domain_annotation}</h4>"
        annotations.preserve_domain_class(prefix, class_name)
      end
      html += '</td>'
    else
      html += empty_cell
    end
    html += '</tr>'
    form.has_group.sort_by {|x| x.ordinal}.each do |group|
      html += group.to_crf(annotations)
    end
    html += '</table>'
  end

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

end
