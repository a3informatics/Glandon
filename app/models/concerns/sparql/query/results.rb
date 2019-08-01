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
          next if result.element_children.empty?
          @results << Sparql::Query::Results::Result.new(result)
        end
        # variables = doc.xpath("//head/variable/@name").map{|x| x.text.to_sym}
        # doc.xpath("//result").map{|x| x.xpath("binding")}.each do |x|
        #   row = {}
        #   x.each_with_index do |y, index|
        #     value = y.xpath("uri").empty? ? y.xpath("literal").text : Uri.new(uri: y.xpath("uri").text)
        #     row[variables[index]] = value
        #   end
        #   @results << row
        # end
#s3 = Time.now
#puts "S1=#{s2-s1}"
#puts "S2=#{s3-s2}"
      end

      # Results
      #
      # @return [Array] retruns the result array
      def results
        @results
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
        @results.map{|x| triples[x.column(s_var).value.to_s] = x.column(e_var).value}
        #@results.map{|x| triples[x[s_var].to_s] = x[e_var]}
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
        #@results.map{|x| triples[x[s_var].to_s] << {subject: x[s_var], predicate: x[p_var], object: x[o_var]}}
        return triples
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