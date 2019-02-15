# Sparql Result Binding
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Query

    class Results

      class Result

        class Column

          C_CLASS_NAME = self.name

          # Initialize
          #
          # @param [Nokogiri::Node] node the xml node containing the binding. Assumed to point at binding element
          # @return [Void] no return
          def initialize(node) 
            @name = node.attributes["name"].text
            @value = uri_literal(node)
          end

          # Name
          # 
          # @return [String] the name of the binding
          def name
            @name
          end

          # Value
          # 
          # @return [String] the value of the binding
          def value
            @value
          end

          # To Hash
          # 
          # @return [Hash] a hash representation of the class content
          def to_hash
            {name: @name, value: @value.to_s}
          end

        private

          # URI Literal. Extract single value
          def uri_literal(node)
            result = uri_from_node(node)
            return result if result.instance_of? Uri
            return literal_from_node(node)
          end

          # Get the URI result
          def uri_from_node(node)
            result = value_from_node(node, "uri")
            return nil if result.nil?
            return Uri.new(uri: result)
          end

          # Get the literal result
          def literal_from_node(node)
            return value_from_node(node, "literal")
          end

          # Get a value from the node givena path
          def value_from_node(node, path)
            items = node.xpath(path)
            return items.first.text if items.count == 1
            return nil
          end

        end

      end

    end

  end

end    