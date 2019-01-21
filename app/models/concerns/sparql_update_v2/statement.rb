# Sparql Update Statement
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class SparqlUpdateV2::Statement

  C_CLASS_NAME = self.name

  # Initialize
  #
  # @param [Hash] args the hash of arguments
  # @option args [Hash] :subject the subject URI. can be epxressed in a number of ways
  # @option args [Hash] :predicate a URI. can be epxressed in a number of ways
  # @option args [Hash] :object a URI or literal. can be epxressed in a number of ways
  # @return [SparqlUpdateV2::Statement] the object
  def initialize(args, default_namespace, prefix_set) 
    @item = 
      [
        SparqlUpdateV2::StatementUri.new(args[:subject], default_namespace, prefix_set),
        SparqlUpdateV2::StatementUri.new(args[:predicate], default_namespace, prefix_set),
        add_object(args[:object], default_namespace, prefix_set)
      ]
  end

  # To String. Output in prefixed form
  #
  # @return [String] string representation of the object
  def to_s
    "#{@item.map {|i| i.to_s}.join(" ")} . \n"
  end

  # To Prefixed. Output in full URI form
  #
  # @return [String] string representation of the object
  def to_ref
    "#{@item.map {|i| i.to_ref}.join(" ")} . \n"
  end

  # To Tutle
  #
  # @param [String] current the current URI as a string
  # @return [String] turtle string representation of the object
  def to_turtle(current)
    text = @item[0].uri.to_s == current ? "" : ".\n:#{@item[0].uri.id}\n"
    return "#{text}\t#{@item[1].to_turtle}\t#{@item[2].to_turtle} ;\n"
  end

  # Subject
  #
  # @return [UriV2] the subject
  def subject
    return @item[0].uri
  end

private

  # Add object, either URI or Literal
  def add_object(args, default_namespace, prefix_set)
    return SparqlUpdateV2::StatementLiteral.new(args) if args.key?(:literal) 
    SparqlUpdateV2::StatementUri.new(args, default_namespace, prefix_set)
  end

end

    