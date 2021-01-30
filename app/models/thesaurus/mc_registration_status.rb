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
    # @return [Array] array of items, default is just self
    def update_status_dependent_items(operation)
      query_string = %Q{
        SELECT ?s WHERE 
        {
          {
            #{self.uri.to_ref} ^th:subsets ?s
          }
          UNION
          {
            #{self.uri.to_ref} ^th:extends ?s
          }
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.by_object(:s)
    end

  end

end