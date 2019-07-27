# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Identifiers

    # Generated? Is the identifier generated or input by the user?
    def new_identifier
      Errors.application_error(self.class.name, __method__.to_s, "Request to generate identifier when not configured.") if !generated?
      self.class == Thesaurus::ManagedConcept ? parent_identifier : child_identifier
    end

    # Generated? Is the identifier generated or input by the user?
    def generated?
      self.class == Thesaurus::ManagedConcept ? parent_configuration[:generted] : child_configuration[:generted]
    end

    # Generated? Is the identifier generated or input by the user?
    def type
      configuration[:scheme_type]
    end

  private

    def parent_identifier
      value = NameValue.next("thesaurus_parent_identifier")
      identifier(value, parent_configuration)
    end

    def child_identifier
      value = NameValue.next("thesaurus_child_identifier")
      identifier(value, parent_configuration)
    end

    def parent_configuration
      configuration[:parent]
    end
    
    def parent_configuration
      configuration[:child]
    end
    
    def configuration
      ENV["thesauri_identifiers"].deep_symbolize_keys
    end

    def identifier(value, configuration)
      pattern = configuration[:pattern].dup
      pattern.sub!("[identifier]", '%0*d' % [configuration[:width], value])
    end

  end

end