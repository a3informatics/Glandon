class Thesaurus
  
  class Syntax

    def initialize(string)
      @parts = "#{string}".match('^([\S]+)\s(AND|OR)\s([\S]+)(\s-[\S]+)?$|^([\S]+)\s-([\S]+)$|^(\\".*?\\")$|^(.*?)$')
      if !@parts.nil?
        @parts = @parts.captures.reject { |c| c.nil? } #Remove nil elements from array if there is any
      else
        Errors.application_error(self.class.name, __method__.to_s, "No matches")
      end
    end

    def array_to_sparql(column)
      case @parts.length
      when 3
        @parts[1] == "AND" || @parts[1] == "OR" ? type = @parts[1].to_sym : type = nil #AND/OR operator
      when 4
        @parts[1] == "AND" ? type = :AND_MINUS : type = :OR_MINUS #AND MINUS/OR MINUS operator
      when 2
        type = :MINUS #MINUS operator
      when 1
        type = :EXACT
      end
      type_to_sparql(type, @parts, column) 
    end

    def type_to_sparql(type, results, column) 
      case type
      when :AND
        return and_statement(results, column)
      when :OR
        return or_statement(results, column)
      when :MINUS
        return minus_statement(results, column)
      when :AND_MINUS
        return and_minus_statement(results, column)
      when :OR_MINUS
        return or_minus_statement(results, column)
      when :EXACT
        return exact_match_statement(results, column)
      else
        Errors.application_error(self.class.name, __method__.to_s, "Invalid type")
      end
    end

  private
    def or_statement(elements, column)
     sparql = ". FILTER (CONTAINS(UCASE(#{column}), UCASE('#{elements[0]}')) || CONTAINS(UCASE(#{column}), UCASE('#{elements[2]}'))) ."
     return sparql
    end

    def and_statement(elements, column)
     sparql = ". FILTER (CONTAINS(UCASE(#{column}), UCASE('#{elements[0]}')) && CONTAINS(UCASE(#{column}), UCASE('#{elements[2]}'))) ."
     return sparql
    end

    def minus_statement(elements, column)
     sparql = ". FILTER (CONTAINS(UCASE(#{column}), UCASE('#{elements[0]}')) && !CONTAINS(UCASE(#{column}), UCASE('#{elements[1]}'))) ."
     return sparql
    end

    def exact_match_statement(elements, column)
     return ". FILTER (CONTAINS(UCASE(#{column}), UCASE('#{elements[0].gsub("\"", "")}'))) ."
    end

    def and_minus_statement(elements, column)
      sparql = ". FILTER (CONTAINS(UCASE(#{column}), UCASE('#{elements[0]}')) && CONTAINS(UCASE(#{column}), UCASE('#{elements[2]}')) && !CONTAINS(UCASE(#{column}), UCASE('#{elements[3][2..-1]}'))) ."
     return sparql
    end

    def or_minus_statement(elements, column)
      sparql = ". FILTER (CONTAINS(UCASE(#{column}), UCASE('#{elements[0]}')) || CONTAINS(UCASE(#{column}), UCASE('#{elements[2]}')) && !CONTAINS(UCASE(#{column}), UCASE('#{elements[3][2..-1]}'))) ."
     return sparql
    end

    # def default_statement(elements, column)
    #  sparql = " FILTER regex(#{column}, \"#{elements}\", 'i') . \n "
    #  return sparql
    # end
  end
end