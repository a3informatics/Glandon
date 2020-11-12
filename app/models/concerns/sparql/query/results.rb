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
        @ask = false
        doc = Nokogiri::XML(body)
        doc.remove_namespaces!
        doc.xpath("//result").each do |result|
          next if result.element_children.empty?
          @results << Sparql::Query::Results::Result.new(result)
        end
        @ask = doc.xpath("//boolean/text()").first.to_s.to_bool if doc.xpath("//boolean/text()").any?
      end

      # Results
      #
      # @return [Boolean] returns the ask result
      def ask?
        @ask
      end

      # Results
      #
      # @return [Array] returns the result array
      def results
        @results
      end

      # Empty? Empty results
      #
      # @return [Boolean] returns true if empty, false otherwise
      def empty?
        @results.empty?
      end

      # Subject Map. Extract subject mapping to another variable
      #
      # @param [Hash] args the hash of arguments
      # @option args [String|Symbol] :subject the subject column name. Default to :s
      # @option args [String|Symbol] :other the other column name. Defaults to :e
      # @result [Hash] a hash of by subject of the other variable
      def subject_map(args={})
        triples = Hash.new {|h,k| h[k] = []}
        s_var = args.key?(:subject) ? args[:subject] : :s 
        e_var = args.key?(:other) ? args[:other] : :e
        @results.map{|x| triples[x.column(s_var).value.to_s] = x.column(e_var).value}
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
        @results.map{|x| triples[x.column(s_var).value.to_s] << {subject: x.column(s_var).value, predicate: x.column(p_var).value, object: x.column(o_var).value}}
        return triples
      end

      # Single Subject. Extract results by the single subject URI from the node set
      #
      # @param [Hash] args the hash of arguments
      # @option args [String|Symbol] :subject the subject column name. Default to :s
      # @option args [String|Symbol] :predicate the predicate column name. Defaults to :p
      # @option args [String|Symbol] :object the object column name. Defaults to :o
      # @result [Hash] a hash of [subject, predicate, object] hash records or nil if nothing found.
      def single_subject(args={})
        triples = by_subject(args)
        return nil if triples.empty?
        return triples if triples.count == 1
        Errors.application_error(self.class.name, __method__.to_s, "Multiple entries found for single subject query.")
      end

      # Single Subject As. Extract results by the single subject URI from the node set and return as instance.
      #
      # @param [Class] klass the klass desired.
      # @param [Hash] args the hash of arguments
      # @option args [String|Symbol] :subject the subject column name. Default to :s
      # @option args [String|Symbol] :predicate the predicate column name. Defaults to :p
      # @option args [String|Symbol] :object the object column name. Defaults to :o
      # @result [Object] the resulting object, nil if multiple found.
      def single_subject_as(klass, args={})
        triples = single_subject(args)
        triples.nil? ? nil : klass.from_results(Uri.new(uri: triples.keys.first), triples[triples.keys.first])
      end

      # By Object. Extract results as single array of object
      #
      # @param o_var [String|Symbol] the object column name. Defaults to :o
      # @result [Array] an array of values
      def by_object(o_var=:o)
        values = []
        @results.map{|x| values << x.column(o_var).value}
        #@results.map{|x| values << x[o_var]}
        values
      end

      # By Object Set. Extract results as single array of objects in a hash
      #
      # @param [Array] variables an array of string or symbol variables/column names
      # @result [Array] an array of hashes containing the row of data
      def by_object_set(variables)
        values = []
        #@results.map{|x| values << x.slice(variables)}
        @results.each do |result|
          values << result.row(variables)
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