# Thesaurus Search
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus

  module Identifiers

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # New Identifier. Generate a new identifier
      #
      # @return [String] the new identifier
      def new_identifier
        Errors.application_error(self.class.name, __method__.to_s, "Request to generate identifier when not configured.") if !generated_identifier?
        self == Thesaurus::ManagedConcept ? parent_identifier : child_identifier
      end

      # Generated Identifier? Is the identifier generated or input by the user?
      #
      # @return [Boolean] true if the identifier is generated
      def generated_identifier?
        self == Thesaurus::ManagedConcept ? parent_identification_configuration.key?(:generated) : child_identification_configuration.key?(:generated)
      end

      # Identifier Scheme
      #
      # @return [Symbol] the identifier scheme type, either :flat or :hierarchical
      def identifier_scheme
        identification_configuration[:scheme_type].to_sym
      end

      # Identifier Scheme Flat?
      #
      # @return [Boolean] true if the identifier scheme is :flat
      def identifier_scheme_flat?
        identifier_scheme == :flat
      end

    private

      def parent_identifier
        value = NameValue.next("thesaurus_parent_identifier")
        generate_identifier(value, parent_identification_configuration[:generated])
      end

      def child_identifier
        value = NameValue.next("thesaurus_child_identifier")
        generate_identifier(value, child_identification_configuration[:generated])
      end

      def parent_identification_configuration
        identification_configuration[:parent]
      end
      
      def child_identification_configuration
        identification_configuration[:child]
      end
      
      def identification_configuration
        #ENV["thesauri_identifiers"].deep_symbolize_keys
        Rails.configuration.thesauri[:identifiers]
      end

      def generate_identifier(value, configuration)
        pattern = configuration[:pattern].dup
        pattern.sub!("[identifier]", '%0*d' % [configuration[:width].to_i, value])
      end

    end

  end

end