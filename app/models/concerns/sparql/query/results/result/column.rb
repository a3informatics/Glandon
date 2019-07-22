# Sparql Result Binding
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Query

    class Results

      class Result

        class Column

          # Initialize
          #
          # @param [Nokogiri::Node] node the xml node containing the binding. Assumed to point at binding element
          # @return [Void] no return
          def initialize(node)
            str = node.to_s
            @name = str.match(/\A<binding name=\"([a-z]*)\"/)[1]            
            uri = str.match(/<uri>(.*)<\/uri>/)
            if !uri.nil? 
              @value = Uri.new(uri: uri[1])
            else
              literal = str.match(/<literal.*>(.*)<\/literal>/)
              @value = literal.nil? ? "" : convert_xml_chars(literal[1])
            end
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

          # Convert < and > since we are taking the raw XML
          def convert_xml_chars(text)
            text = text.gsub(/&lt;/, '<')
            text.gsub(/&gt;/, '>')
          end

        end

      end

    end

  end

end    