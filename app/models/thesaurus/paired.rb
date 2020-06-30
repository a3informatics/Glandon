# Managed Concepts Pair
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class Thesaurus

  module Paired

    # Validate And Pair. Check if items can be paired. If so do it, otherwise report an error.
    #
    # @param [String] id id of the other the potential paired code list (child)
    # @return [Boolean] returns true if pairing succesful, otherwise false. Errors in errors object.
    def validate_and_pair(id)
      other = self.class.find_with_properties(id)
      valid_pairing?(other) ? pair(id) : self.errors.add(:base, "Paring not permitted, trying to pair #{self.notation} with #{other.notation}.")
      self.errors.empty?
    end

    # Valid Pairing. Is the pairing a valid one.
    #
    # @param [Thesaurus::ManagedConcept] other the potential paired code list (child)
    # @return [Boolean] returns true if pairing is permitted, false otherwise.
    def valid_pairing?(other)
      result = nil
      Rails.configuration.thesauri[:permitted_pairing].each do |config|
        next unless check_rule(config, :parent, self.notation)
        result = config
        break
      end
      return false if result.nil?
      return false unless check_rule(result, :child, other.notation)
      check_prefix(result, other)
    end

    # Paired As Parent? Is this item paired as the parent
    #
    # @result [Boolean] return true if this instance is ranked
    def paired?
      query_string = %Q{
        ASK {{#{self.uri.to_ref} th:pairedWith ?o} UNION {?s th:pairedWith #{self.uri.to_ref}}}
      }
      Sparql::Query.new.query(query_string, "", [:th]).ask? 
    end

    # Paired As Parent? Is this item paired as the parent
    #
    # @result [Boolean] return true if this instance is ranked
    def paired_as_parent?
      Sparql::Query.new.query("ASK {#{self.uri.to_ref} th:pairedWith ?o}", "", [:th]).ask? 
    end

    # Paired As Child? Is this item paired as the parent
    #
    # @result [Boolean] return true if this instance is ranked
    def paired_as_child?
      Sparql::Query.new.query("ASK {?s th:pairedWith #{self.uri.to_ref}}", "", [:th]).ask? 
    end

    # Pair. Pair the code list as the parent with the specified other code list as the child. 
    #
    # @param [Uri|String] id the identifier, either a URI or the id
    # @return [Void] no return.
    def pair(id)
      uri = id.is_a?(Uri) ? id : Uri.new(id: id)
      self.add_link(:paired_with, uri)
    end

    # Unpair. Remove the pairing from the parent.
    #
    # @return [Void] no return.
    def unpair
      self.paired_with_links
      self.delete_link(:paired_with, self.paired_with)
    end

    # Other Pair. Find the other end of the paired relationship.
    #
    # @raise [Errors::ApplicationLogicError] raised if no paired code list found or multiple found.
    # @return [Thesaurus::ManagedConcept] the object paired with
    def other_pair
      objects = []
      query_string = %Q{
        SELECT DISTINCT ?o WHERE {
          {
            #{self.uri.to_ref} ^th:pairedWith ?o
          } 
          UNION
          {
            #{self.uri.to_ref} th:pairedWith ?o
          }
        }
      }
      results = Sparql::Query.new.query(query_string, "", [:th]).by_object
      return self.class.find_minimum(results.first) if results.count == 1
      Errors.application_error(self.class.name, __method__.to_s, "Failed to find single paired code list.")
    end

  private

    # Check individual pairing rule, parent or child match the config.
    def check_rule(config, field, value)
      str = config[field]
      return false if value.length < str.length
      return value[-str.length..-1] == str
    end

    # Make sure prefixes match, e.g. nn is the same in nnTESTCD & nnTEST
    def check_prefix(config, other)
      return self.notation[0..-config[:parent].length] == other.notation[0..-config[:child].length]
    end

  end

end