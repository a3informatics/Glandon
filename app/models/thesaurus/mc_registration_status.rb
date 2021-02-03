# Thesaurus Custom Property
#
# @author Dave Iberson-Hurst
# @since 3.4.0
class Thesaurus

  module McRegistrationStatus

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # Update Status Dependent Items. The depedent items that we could update. Default method always return no items.
    #
    # @param params [Hash] the options to create a message with.
    # @option params [String] :with_dependencies boolean flag to use dependencies
    # @return [Array] array of items, default is just self
    def update_status_dependent_items(params)
      results = []
      return results unless params.key?(:with_dependencies) && params[:with_dependencies].to_bool
      query_string = %Q{
        SELECT ?s WHERE 
        {
          #{self.uri.to_ref} (^th:subsets|^th:extends) ?s
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.by_object(:s)
    end

  end

end