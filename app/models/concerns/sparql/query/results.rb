# Sparql Statement
#
# @author Dave Iberson-Hurst
# @since 2.21.1
module Sparql

  class Query

    class Results

      C_CLASS_NAME = self.name

      # Initialize
      #
      # @param [Hash] args the hash of arguments
      # @option args [Hash] :subject the subject URI. can be epxressed in a number of ways
      # @option args [Hash] :predicate a URI. can be epxressed in a number of ways
      # @option args [Hash] :object a URI or literal. can be epxressed in a number of ways
      # @return [SparqlUpdateV2::Statement] the object
      def initialize(body) 
        @results = []
        doc = Nokogiri::XML(body)
        doc.remove_namespaces!
        doc.xpath("//result").each do |result|
          @results << Sparql::Query::Results::Result.new(result)
        end
      end

      # Empty? Empty results
      #
      # @return [Boolean] returns true if empty, false otherwise
      def empty?
        @results.empty?
      end

      def subject_map(args={})
        triples = Hash.new {|h,k| h[k] = []}
        s_var = args.key?(:subject) ? args[:subject] : :s 
        e_var = args.key?(:other) ? args[:other] : :e
        @results.each do |result|
          s_uri = result.column(s_var).value
          triples[s_uri.to_s] = result.column(e_var).value
        end
        return triples
      end

      # By Subject. Extract results by subject URI from the node set
      #
      # @param [Hash] args the hash of arguments
      # @option args [String|Symbol] :subject the subject column name. Default to :s
      # @option args [String|Symbol] :predicate the predicate column name. Defaults to :p
      # @option args [String|Symbol] :object the object column name. Defaults to :o
      # @result [Hash] a hash of [subject, predicate, object] hash records
      def by_subject(args={})
        triples = Hash.new {|h,k| h[k] = []}
        s_var = args.key?(:subject) ? args[:subject] : :s 
        p_var = args.key?(:predicate) ? args[:predicate] : :p
        o_var = args.key?(:object) ? args[:object] : :o 
        @results.each do |result|
          s_uri = result.column(s_var).value
          triples[s_uri.to_s] << {subject: s_uri, predicate: result.column(p_var).value, object: result.column(o_var).value}
        end
        return triples
      end

      # By Object. Extract results as single array of object
      #
      # @param o_var [String|Symbol] the object column name. Defaults to :o
      # @result [Hash] a hash of [subject, predicate, object] hash records
      def by_object(o_var=:o)
        values = []
        @results.each do |result|
          values << result.column(o_var).value
        end
        values
      end

      # To Hash
      # 
      # @return [Hash] a hash representation of the class content
      def to_hash
        @results.map {|v| v.to_hash}
      end

    end

  end
  
end    