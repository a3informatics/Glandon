# ISO Concept V2. Methods for handling of managed ancestors (parent managed items) operations.
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class IsoConceptV2

  module ManagedAncestors

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Managed Ancestors Path. Returns the path from the managed ancestor to this class
      #
      # @raise [Errors::ApplicationLogicError] raised to indicate the class has not configured the method
      # @return [Void] exception always raised
      def managed_ancestors_path
        Errors.application_error(self.name, the_method, "Method not implemented for class.")
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Managed Ancestors Children Set. Returns the set of clidren nodes. Normally this is children but can be a combination.
    #
    # @return [Array] array of predicates (symbols)
    def managed_ancestors_children_set
      children
    end

    # Managed Ancestors Predicate. Returns the property(ies) from this instance/class in the managed ancestor path to the child class
    #
    # @param [Class] the child klass
    # @return [Array] array of predicates (symbols)
    def managed_ancestors_predicate(child_klass)
      return [self.class.children_property_name] if child_klass.ancestors.include?(self.class.children_klass)
      Errors.application_error(self.class.name, __method__.to_s, "Need to override the method to return the correct predicate(s). Classes are #{self.class.children_klass} and #{child_klass}.")
    end

    # Managed Ancestor URIs. Find all the URIs of the managed ancstors of this concept.
    #
    # @return [Array] Array of hash containing details of the found ancestors
    def managed_ancestor_uris
      query_string = %Q{
        SELECT ?uri ?identifier ?scope ?type WHERE {
          ?component rdfs:subClassOf* bo:Component .  
          ?uri rdf:type ?component .
          ?uri rdf:type ?type .
          ?uri #{self.class.managed_ancestors_path.join("/")} #{self.uri.to_ref} .
          ?uri isoT:hasIdentifier ?si .
          ?si isoI:identifier ?identifier .
          ?si isoI:hasScope ?scope .
        }
      }
      triples = Sparql::Query.new.query(query_string, "", [:isoT, :isoI, :bo])
      results = triples.by_object_set([:uri, :identifier, :scope, :type])
      results
    end

    # Multipe Managed Ancestors? Are there multiple managed ancestors attached to this concept.
    #
    # @return [Boolean] true if multiple ancestors found, otherwise false
    def multiple_managed_ancestors?
      managed_ancestor_uris.count > 1
    end

    # No Managed Ancestors? Are there no managed ancestors attached to this concept.
    #
    # @return [Boolean] true if no ancestors found, otherwise false
    def no_managed_ancestors?
      managed_ancestor_uris.empty?
    end

    # Managed Ancestors? Are there managed ancestors attached to this concept.
    #
    # @return [Boolean] true if ancestors found, otherwise false
    def managed_ancestors?
      managed_ancestor_uris.any?
    end

    # Managed Ancestor Path Objects
    #
    # @param [Object] managed_ancestor the managed ancestor at the start of the path
    # @result [Array] array of URIs for the objects ordered from the ancestor to this object.
    def managed_ancestor_path_uris(managed_ancestor)
      objects = []
      parts = managed_ancestor_path_query(managed_ancestor)
      query_string = %Q{
        SELECT DISTINCT ?s WHERE {
          {#{parts.join("} UNION {")}}
        } ORDER BY ?index
      }
      results = Sparql::Query.new.query(query_string, "", [])
      results.by_object(:s)
    end

    # Update With Clone. Update the object. Clone if there are multiple parents,
    #
    # @param [Hash] params the parameters to be updated
    # @param [Object] parent_object the parent object
    # @return [Thesarus::UnmanagedConcept] the object, either new or the cloned new object with updates
    def update_with_clone(params, managed_ancestor)
      @parent_for_validation = managed_ancestor
      if multiple_managed_ancestors?
        result = nil
        tx, persist_objects, uris, prev_object = managed_ancestor_prepare(managed_ancestor, self)
        uris.each do |old_uri|
          old_object = self.class.klass_for(old_uri).find_children(old_uri)
          if old_object.multiple_managed_ancestors?
            cloned_object = clone_with_optional_update(managed_ancestor, old_object, prev_object, persist_objects, tx, params)
            result = cloned_object if self.uri == old_object.uri
            replace_links(prev_object, old_object, cloned_object, managed_ancestor)
            prev_object = cloned_object
          else
            prev_object = old_object
          end
        end
        commit_changes(persist_objects, tx)
        result
      else
        self.update(params)
      end
    end

    # Replicate With Clone. Replicate the object by cloning with all the nodes in the ancestor chain.
    #
    # @param [Object] child the target object
    # @param [Object] managed_ancestor the managed ancestor
    # @return [Object, Object] the new parent and target objects
    def replicate_with_clone(child, managed_ancestor)
      new_parent = nil
      new_object = nil
      tx, persist_objects, uris, prev_object = managed_ancestor_prepare(managed_ancestor, self)
      uris.each do |old_uri|
        old_object = self.class.klass_for(old_uri).find_children(old_uri)
        if old_object.multiple_managed_ancestors?
          cloned_object = clone_with_optional_update(managed_ancestor, old_object, prev_object, persist_objects, tx, {})
          new_object = cloned_object if self.uri == old_object.uri
          replace_links(prev_object, old_object, cloned_object, managed_ancestor)
          prev_object = cloned_object
        else
          prev_object = old_object
        end
      end
      commit_changes(persist_objects, tx)
      new_object
    end

    # Replicate Siblings With Clone. Clone all the ancestor chain. Self is the parent
    #
    # @param [Object] child the target object
    # @param [Object] managed_ancestor the managed ancestor
    # @return [Object, Object] the new parent and target objects
    def replicate_siblings_with_clone(child, managed_ancestor)
      new_parent = nil
      new_object = nil
      tx, persist_objects, uris, prev_object = managed_ancestor_prepare(managed_ancestor, child)
      uris.each do |old_uri|
        old_object = self.class.klass_for(old_uri).find_children(old_uri)
        if old_object.multiple_managed_ancestors?
          if child.uri == old_object.uri
            new_parent = prev_object
            new_object, persist_objects = clone_children_with_note(self, new_parent, managed_ancestor, persist_objects, tx, child.uri) 
          else
            cloned_object = clone_with_optional_update(managed_ancestor, old_object, prev_object, persist_objects, tx, {})
            replace_links(prev_object, old_object, cloned_object, managed_ancestor)
            prev_object = cloned_object
          end
        else
          prev_object = old_object
        end
      end
      commit_changes(persist_objects, tx)
      return new_parent, new_object
    end

    # Delete With Clone. Clone all the ancestor chain and delete the node
    #
    # @param [Object] managed_ancestor the managed ancestor
    # @return [Object] the new parent
    def delete_with_clone(parent, managed_ancestor)
      new_parent = nil
      tx, persist_objects, uris, prev_object = managed_ancestor_prepare(managed_ancestor, self)
      uris.each do |old_uri|
        old_object = self.class.klass_for(old_uri).find_children(old_uri)
        if self.uri == old_object.uri
          delete_links(prev_object, old_object, managed_ancestor)
          new_parent = prev_object
          new_object, persist_objects = clone_children_with_ignore(parent, new_parent, managed_ancestor, persist_objects, tx, self.uri)
        else
          cloned_object = clone_with_optional_update(managed_ancestor, old_object, prev_object, persist_objects, tx, {})
          persist_objects << cloned_object
          replace_links(prev_object, old_object, cloned_object, managed_ancestor)
        end
        prev_object = cloned_object
      end
      commit_changes(persist_objects, tx)
      new_parent
    end

  private

    # Prepare for a managed ancestor operation
    def managed_ancestor_prepare(managed_ancestor, target)
      tx = transaction_begin
      persist_objects = []
      uris = target.managed_ancestor_path_uris(managed_ancestor)
      # @todo This should be true objects.last.uri == self.uri. Could add a check and exception
      prev_object = managed_ancestor
      prev_object.transaction_set(tx)
      return tx, persist_objects, uris, prev_object
    end

    # Form path query
    def managed_ancestor_path_query(managed_ancestor)
      elements = self.class.managed_ancestors_path
      parts = ancestor_parts(elements, managed_ancestor)
      parts << %Q{
        BIND (#{self.uri.to_ref} as ?s)
        BIND(#{elements.count} as ?index)
      }
      parts
    end

    # Form path query ancestor parts
    def ancestor_parts(elements, managed_ancestor)
      return [] if elements.length <= 1
      path = ""
      parts = []
      elements[0..elements.length-2].each_with_index do |e, i|
        path += "#{e}"
        parts << %Q{
          #{managed_ancestor.uri.to_ref} #{path} ?s . 
          ?s #{elements[i+1..elements.count-1].join("/")} #{self.uri.to_ref} .
          BIND(#{i+1} as ?index)
        }
        path += "/"
      end
      parts
    end 

    # Clone the item with an update if necessary. Note the setting of the transaction in the cloned object
    def clone_with_optional_update(managed_ancestor, child, parent, persist_objects, tx, params={})
      object = child.clone
      object.transaction_set(tx)
      object.generate_uri(parent.uri) 
      object.update(params) if self.uri == child.uri && !params.empty?
      uri_updated(managed_ancestor, child.uri, object.uri)
      persist_objects << object
      object
    end

    # Clone Children With Note
    def clone_children_with_note(source, the_object, managed_ancestor, persist_objects, tx, save_uri)
      clone_children(source, the_object, managed_ancestor, persist_objects, tx, save_uri, nil)
    end

    # Clone Children With Ignore
    def clone_children_with_ignore(source, the_object, managed_ancestor, persist_objects, tx, ignore_uri)
      clone_children(source, the_object, managed_ancestor, persist_objects, tx, nil, ignore_uri)
    end

    # Clone the children. It will ignore the object (it won't be cloned) if ignore_uri is not nil and it'll save it if save_uri is passed.
    def clone_children(source, the_object, managed_ancestor, persist_objects, tx, save_uri=nil, ignore_uri=nil)
      new_object = nil
      #items = Hash.new {|h,k| h[k] = []}
      source.managed_ancestors_children_set.each do |child|
        next if !ignore_uri.nil? && ignore_uri == child.uri
        object = child.clone
        object.transaction_set(tx)
        object.generate_uri(the_object.uri) 
        #predicate = child.managed_ancestors_predicate
        replace_links(the_object, child, object, managed_ancestor)
        #items[predicate] << object
        persist_objects << object
        unless save_uri.nil? 
          new_object = object if child.uri == save_uri 
        end 
        uri_updated(managed_ancestor, child.uri, object.uri)
      end
      #items.each do |predicate, object_array|
      #  the_object.send("#{predicate}=".to_sym, object_array)
      #end
      return new_object, persist_objects
    end

    # Commit Changes. Commit the set of changes
    def commit_changes(objects, tx)
      sparql = Sparql::Update.new(tx)
      objects.each do |object|
        object.to_sparql(sparql, true)
      end
      sparql.create
      transaction_execute
    end

    # Replace links
    def replace_links(parent_object, old_object, new_object, managed_ancestor)
      predicates = parent_object.managed_ancestors_predicate(old_object.class)
      predicates.each do |predicate|
        #if parent_object.uri == managed_ancestor.uri
        if parent_object.persisted?
          parent_object.replace_link(predicate, old_object.uri, new_object.uri)
        else
          parent_object.properties.property(predicate).replace_value(old_object.uri, new_object.uri)
        end
      end
    end

    # Delete links
    def delete_links(parent_object, old_object, managed_ancestor)
      predicates = parent_object.managed_ancestors_predicate(old_object.class)
      predicates.each do |predicate|
        #if parent_object.uri == managed_ancestor.uri
        if parent_object.persisted?
          parent_object.delete_link(predicate, old_object.uri)
        else
          parent_object.properties.property(predicate).delete_value(old_object.uri)
        end
      end
    end  

    # Log the change in a URI
    def uri_updated(managed_ancestor, old_uri, new_uri)
      managed_ancestor.add_modified_uri(old_uri, new_uri)
    end

  end

end