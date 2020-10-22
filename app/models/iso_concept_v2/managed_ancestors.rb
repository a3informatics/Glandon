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
        Errors.application_error(self.name, __method__.to_s, "Method not implemented for class.")
      end

      # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
      #
      # @raise [Errors::ApplicationLogicError] raised to indicate the class has not configured the method
      # @return [Void] exception always raised
      def managed_ancestors_predicate
        Errors.application_error(self.name, __method__.to_s, "Method not implemented for class.")
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

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
        SELECT ?s WHERE {
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
      if multiple_managed_ancestors?
        result = nil
        tx = transaction_begin
        uris = managed_ancestor_path_uris(managed_ancestor)
        # @todo This should be true objects.last.uri == self.uri
        #   Could add an check and exception
        prev_object = managed_ancestor
        prev_object.transaction_set(tx)
        uris.each do |old_uri|
          old_object = self.class.klass_for(old_uri).find_children(old_uri)
          if old_object.multiple_managed_ancestors?
            cloned_object = clone_update_and_save(old_object, params, prev_object, tx)
            result = cloned_object if self.uri == old_object.uri
            prev_object.replace_link(old_object.managed_ancestors_predicate, old_object.uri, cloned_object.uri)
            prev_object = cloned_object
          else
            prev_object = old_object
          end
        end
        transaction_execute
        result
      else
        self.update(params)
      end
    end

  private

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

    # Clone the item, update if necessary and create. Use Sparql approach in case of children also need creating
    #   so we need to recruse. Also generate URI for this object and any children to ensure we catch the children.
    #   The Children are normally references. Also note the setting of the transaction in the cloned object and
    #   in the sparql generation, important both are done.
    def clone_update_and_save(child, params, parent, tx)
      object = child.clone
      object.transaction_set(tx)
      object.generate_uri(parent.uri) 
      object.update(params) if self.uri == child.uri
      sparql = Sparql::Update.new(tx)
      object.to_sparql(sparql, true)
      sparql.create
      object
    end

  end

end