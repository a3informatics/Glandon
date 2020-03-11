class Thesaurus
  
  class Syntax

    def initialize(string)
      @parts = "#{string}".split(" ")
    end



    def string_to_sparql
      results = []
      and_flag = false
      or_flag = false
      minus_flag = false
      exact_match_flag = false
      @parts.each do |item|
        if item == "AND"
          and_flag = true
        elsif item == "OR"
          or_flag = true
        elsif item.start_with?("-") && item.size > 1 #MINUS operator
          minus_flag = true
          results << item[1..-1] #Extracts the dash
        elsif item.include?("\"") #EXACT MATCH
          exact_match_flag = true
          results << item.gsub("\"", "") #Extracts escape string
        else
           results << item
        end
      end
      check_flags(and_flag, or_flag, minus_flag, exact_match_flag, results)
    end

    def check_flags(and_flag, or_flag, minus_flag, exact_match_flag, results) 
      if and_flag
        if minus_flag
          and_minus_statement(results)
        else
         and_statement(results)
        end
      elsif or_flag
        if minus_flag
          or_minus_statement(results)
        else
          or_statement(results)
        end
      elsif minus_flag
        minus_statement(results)
      elsif exact_match_flag
        exact_match_statement(results)
      else 
         Errors.application_error(self.class.name, __method__.to_s, "Invalid syntax")
      end
    end

  private

    def or_statement(elements)
     sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') || CONTAINS(?x, '#{elements[1]}')) ."
     return sparql
    end

    def and_statement(elements)
     sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') && CONTAINS(?x, '#{elements[1]}')) ."
     return sparql
    end

    def minus_statement(elements)
     sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') && !CONTAINS(?x, '#{elements[1]}')) ."
     return sparql
    end

    def exact_match_statement(elements)
     return ". FILTER (CONTAINS(UCASE(?x), UCASE('#{elements.join(" ")}'))) ."
    end

    def and_minus_statement(elements)
      sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') && CONTAINS(?x, '#{elements[1]}') && !CONTAINS(?x, '#{elements[2]}')) ."
     return sparql
    end

    def or_minus_statement(elements)
      sparql = ". FILTER (CONTAINS(?x, '#{elements[0]}') || CONTAINS(?x, '#{elements[1]}') && !CONTAINS(?x, '#{elements[2]}')) ."
     return sparql
    end
    
  end
end