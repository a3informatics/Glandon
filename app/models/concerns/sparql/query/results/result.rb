# Sparql Query Results Result. 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Query

    class Results

      class Result

        C_CLASS_NAME = self.name

        # Initialize
        #
        # @param [Nokogiri::Node] the node
        # @return [Sparql::Query::Results::Result] the object
        def initialize(node) 
          @columns = {}
          node.xpath("binding").each do |b|
            object = Sparql::Query::Results::Result::Column.new(b)
            @columns[object.name.to_sym] = object
          end
        end
      
        # Column
        #
        # @param name [String|Symbol] the name of the column
        # @return [Sparql::Query::Results::Result::Column] the column object or nil if not found
        def column(name)
          @columns[name.to_sym]
        end

        # To Hash
        # 
        # @return [Hash] a hash representation of the class content
        def to_hash
          @columns.map {|k, v| v.to_hash}
        end

      end

    end

  end
  
end    