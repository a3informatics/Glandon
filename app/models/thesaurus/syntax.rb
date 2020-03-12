class Thesaurus
  
  class Syntax

    def initialize(string)
      @parts = "#{string}".match(/^("*[\S]+"*)\s*([AND|OR]*)\s*([\S]*)\s*([-\S*]*)$/).captures #Array with 4 elements (It could have blank elements)
      @parts = @parts.reject { |c| c.empty? } #Remove blank elements from array if there is any 
    end

    def array_to_sparql
      case @parts.length
      when 3
        @parts[1] == "AND" || @parts[1] == "OR" ? type = @parts[1].to_sym : type = nil #AND or OR operator
      when 4
        @parts[1] == "AND" ? type = :AND_MINUS : type = :OR_MINUS #AND MINUS or OR MINUS operator
      when 2
        type = :MINUS #MINUS operator
      when 1
        type = :EXACT #We assume just one word?
      else 
         Errors.application_error(self.class.name, __method__.to_s, "Invalid syntax")
      end
      type_to_sparql(type, @parts) 
    end

    def type_to_sparql(type, results) 
      case type
      when :AND
        return and_statement(results)
      when :OR
        return or_statement(results)
      when :MINUS
        return minus_statement(results)
      when :AND_MINUS
        return and_minus_statement(results)
      when :OR_MINUS
        return or_minus_statement(results)
      when :EXACT
        return exact_match_statement(results)
      else
        Errors.application_error(self.class.name, __method__.to_s, "Invalid type")
      end
    end

  private

    def or_statement(elements)
     sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') || CONTAINS(?x, '#{elements[2]}')) ."
     return sparql
    end

    def and_statement(elements)
     sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') && CONTAINS(?x, '#{elements[2]}')) ."
     return sparql
    end

    def minus_statement(elements)
     sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') && !CONTAINS(?x, '#{elements[1][1..-1]}')) ."
     return sparql
    end

    def exact_match_statement(elements)
     return ". FILTER (CONTAINS(UCASE(?x), UCASE('#{elements[0].gsub("\"", "")}'))) ."
    end

    def and_minus_statement(elements)
      sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') && CONTAINS(?x, '#{elements[2]}') && !CONTAINS(?x, '#{elements[3][1..-1]}')) ."
     return sparql
    end

    def or_minus_statement(elements)
      sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') || CONTAINS(?x, '#{elements[2]}') && !CONTAINS(?x, '#{elements[3][1..-1]}')) ."
     return sparql
    end
    
  end
end