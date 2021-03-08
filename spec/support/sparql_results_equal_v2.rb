require 'rspec'

RSpec::Matchers.define :sparql_results_equal_v2 do |expected|
  match { |actual| match? actual, expected }

  match_when_negated { |actual| !match? actual, expected }

  failure_message do |actual|
    text = "Following differences were detected:\n"
    @mismatches.each {|x| text += "#{x}\n"}
    text
  end

  failure_message_when_negated do |actual|
    "expected that actual -->\n#{actual}\n would not be sparql results equal with expected -->\n#{expected}"
  end

  description do
    "sparql equal with #{expected}"
  end

  def match?(actual, expected)
    processed = {}
    @a_subjects = Subjects.new
    @e_subjects = Subjects.new
    @actual_refs = {}
    @expected_refs = {}
    @actual_classifications = Hash.new { |h,k| h[k] = [] }
    @expected_classifications = Hash.new { |h,k| h[k] = [] }
    @actual_custom = Hash.new { |h,k| h[k] = [] }
    @expected_custom = Hash.new { |h,k| h[k] = [] }
    @mismatches = []
    return false if !actual[:checks]
    @mismatches << "***** Warning, prefix count mismatch. a=#{actual[:prefixes].count} versus e=#{expected[:prefixes].count}*****" if actual[:prefixes].count != expected[:prefixes].count
    @mismatches << "***** Warning, triple count mismatch. a=#{actual[:triples].count} versus e=#{expected[:triples].count} *****" if actual[:triples].count != expected[:triples].count
    actual[:triples].each do |triple|
      @a_subjects.add(triple)
    end
    expected[:triples].each do |triple|
      @e_subjects.add(triple)
    end
    actual[:triples].each do |triple|
      processed[triple_key(triple)] = triple
      map_reference(@actual_refs, triple)
      map_classifications(@a_subjects, @actual_classifications, triple)
      map_custom(@a_subjects, @actual_custom, triple)
    end
    expected[:triples].each do |triple|
      map_reference(@expected_refs, triple)
      map_classifications(@e_subjects, @expected_classifications, triple)
      map_custom(@e_subjects, @expected_custom, triple)
    end
    expected[:prefixes].each do |prefix|
      found = actual[:prefixes].select {|r| r == prefix}
      @mismatches << "***** Prefix not found: #{prefix}. *****" if found.count != 1
    end
    expected[:triples].each do |item|
      key = triple_key(item)
      triple = processed[key]
      next if !triple.nil?
      next if triple.nil? && is_reference?(item)
      next if triple.nil? && is_origin?(item)
      next if triple.nil? && is_classification?(@e_subjects, item)
      next if triple.nil? && is_custom?(@e_subjects, item)
      e_subject = @e_subjects.subject(item)
      next if e_subject.ignore?
      a_subject = @a_subjects.subject(item)
      next if subsets_equal?(a_subject, e_subject)
      next if ranks_equal?(a_subject, e_subject)
      @mismatches << "***** Triple not matched: [#{item[:subject]}, #{item[:predicate]}, #{item[:object]}]. *****" if triple.nil?
    end
    check_references
    check_classifications
    check_custom
    @mismatches.empty?
  end

  def subsets_equal?(a_subject, e_subject)
    return true if a_subject.is_subset? && e_subject.is_subset? && @a_subjects.subset_items(a_subject) == @e_subjects.subset_items(e_subject)
    #@mismatches << "***** Subset mismatch, actual subset?: #{a_subject.is_subset?}"
    #@mismatches << "***** Subset mismatch, expected subset?: #{e_subject.is_subset?}"
    #@mismatches << "***** Subset mismatch, actual items:\n#{@a_subjects.subset_items(a_subject)}"
    #@mismatches << "***** Subset mismatch, expected items:\n#{@e_subjects.subset_items(e_subject)}"
    false
  end

  def ranks_equal?(a_subject, e_subject)
    return true if a_subject.is_ranked? && e_subject.is_ranked? && @a_subjects.rank_items(a_subject) == @e_subjects.rank_items(e_subject)
    #@mismatches << "***** Subset mismatch, actual subset?: #{a_subject.is_subset?}"
    #@mismatches << "***** Subset mismatch, expected subset?: #{e_subject.is_subset?}"
    false
  end

  def triple_key(triple)
    return "#{triple[:subject]}.#{triple[:predicate]}.#{triple[:object]}"
  end

  def map_reference(collection, triple)
    return if !is_reference?(triple)
    collection[triple[:object]] = triple[:object]
  end

  def map_classifications(subjects, collection, triple)
    return if !is_classification?(subjects, triple)
    collection[triple[:object]] << triple[:subject]
  end

  def map_custom(subjects, collection, triple)
    return if !is_custom?(subjects, triple)
    collection[triple[:object]] << triple[:subject]
  end

  def is_reference?(triple)
    triple[:predicate] == "<http://www.assero.co.uk/BusinessOperational#reference>"
  end

  def is_classification?(subjects, triple)
    return false if triple[:predicate] != "<http://www.assero.co.uk/ISO11179Concepts#appliesTo>" 
    subject = subjects.subject(triple) 
    subject.is_classification?
  end

  def is_custom?(subjects, triple)
    return false if triple[:predicate] != "<http://www.assero.co.uk/ISO11179Concepts#appliesTo>" 
    subject = subjects.subject(triple) 
    subject.is_custom?
  end

  def is_origin?(triple)
    triple[:predicate] == "<http://www.assero.co.uk/ISO11179Types#origin>"
  end

  def check_references
    reference_count
    reference_match
  end

  def check_classifications
    classifications_count
    classifications_keys_match
    classifications_values_match
  end

  def check_custom
    custom_count
    custom_keys_match
    custom_values_match
  end

  def reference_count    
    return if @actual_refs.keys.count == @expected_refs.keys.count
    @mismatches << "***** Reference count mismatch [a: #{@actual_refs.keys.count}, e: #{@expected_refs.keys.count}] *****" 
  end

  def reference_match
    return if references_match?
    add_mismatch("Reference", @actual_refs.keys - @expected_refs.keys)
    add_mismatch("Reference", @expected_refs.keys - @actual_refs.keys)
  end

  def classifications_count    
    return if @actual_classifications.keys.count == @expected_classifications.keys.count
    @mismatches << "***** Classification count mismatch [a: #{@actual_classifications.keys.count}, e: #{@expected_classifications.keys.count}] *****" 
  end

  def custom_count    
    return if @actual_custom.keys.count == @expected_custom.keys.count
    @mismatches << "***** Custom count mismatch [a: #{@actual_custom.keys.count}, e: #{@expected_custom.keys.count}] *****" 
  end

  def classifications_keys_match
    return if classifications_keys_match?
    add_mismatch("Classification", @actual_classifications.keys - @expected_classifications.keys)
    add_mismatch("Classification", @expected_classifications.keys - @actual_classifications.keys)
  end

  def custom_keys_match
    return if custom_keys_match?
    add_mismatch("Custom", @actual_custom.keys - @expected_custom.keys)
    add_mismatch("Custom", @expected_custom.keys - @actual_custom.keys)
  end

  def classifications_values_match
    return if classifications_values_match?
  end

  def custom_values_match
    return if custom_values_match?
  end

  def add_mismatch(type, items)
    items.each do |item|
      @mismatches << "***** #{type} mismatch for #{item} *****"
    end
  end

  def references_match?
    return false if !reference_keys_match?
    #puts colourize("Matching reference keys", "blue") 
    true
  end

  def classifications_keys_match?
    return false unless classifications_keys_equal?
    #puts colourize("Matching classification keys", "blue") 
    true
  end

  def custom_keys_match?
    return false unless custom_keys_equal?
    #puts colourize("Matching custom keys", "blue") 
    true
  end

  def classifications_values_match?
    return false unless classifications_values_equal?
    #puts colourize("Matching classification values", "blue") 
    true
  end

  def custom_values_match?
    return false unless custom_values_equal?
    #puts colourize("Matching custom values", "blue") 
    true
  end

  def reference_keys_match?
    @actual_refs.keys - @expected_refs.keys == [] && @expected_refs.keys - @actual_refs.keys == []
  end

  def classifications_keys_equal?
    @actual_classifications.keys - @expected_classifications.keys == [] && @expected_classifications.keys - @actual_classifications.keys == []
  end

  def custom_keys_equal?
    @actual_custom.keys - @expected_custom.keys == [] && @expected_custom.keys - @actual_custom.keys == []
  end

  def classifications_values_equal?
    result = true
    @actual_classifications.each do |key, value|
      a_results = @a_subjects.classification_items(value)
      e_value = @expected_classifications[key]
      e_results = @e_subjects.classification_items(e_value)
      this_result = a_results == e_results
      result = result && this_result 
      @mismatches << "***** Classification mismatch #{key}" unless this_result
    end
    result
  end

  def custom_values_equal?
    result = true
    @actual_custom.each do |key, value|
      a_results = @a_subjects.custom_items(value)
      e_value = @expected_custom[key]
      e_results = @e_subjects.custom_items(e_value)
      this_result = a_results == e_results
      result = result && this_result 
      @mismatches << "***** Custom value mismatch #{key}" unless this_result
    end
    result
  end
  class Subjects

    def initialize 
      @subjects = Hash.new {|h,k| h[k] = Subject.new}
    end

    def add(triple)
      key = triple[:subject]
      subject = @subjects[key]
      subject.add(triple)
      subject
    end

    def subject(triple)
      @subjects[triple[:subject]]
    end

    def subset_items(subject)
      uri = subject.object_for("<http://www.assero.co.uk/Thesaurus#isOrdered>")
      subset_list(@subjects[uri].object_for("<http://www.assero.co.uk/Thesaurus#members>"))
    end

    def rank_items(subject)
      uri = subject.object_for("<http://www.assero.co.uk/Thesaurus#isRanked>")
      subset_list(@subjects[uri].object_for("<http://www.assero.co.uk/Thesaurus#members>"))
    end

    def classification_items(subject)
      classifications(subject)
    end

    def custom_items(subject)
      custom(subject)
    end

  private

    def subset_list(uri, depth=0)
      #puts colourize("Subset List: #{uri}, Depth: #{depth}", "blue") 
      subject = @subjects[uri]
      object = subject.object_for("<http://www.assero.co.uk/Thesaurus#memberNext>")
      return [subject.object_for("<http://www.assero.co.uk/Thesaurus#item>")] if object.nil?
      [subject.object_for("<http://www.assero.co.uk/Thesaurus#item>")] + subset_list(object, depth + 1)  
    end

    def rank_list(uri, depth=0)
      #puts colourize("Rank List: #{uri}, Depth: #{depth}", "blue") 
      subject = @subjects[uri]
      object = subject.object_for("<http://www.assero.co.uk/Thesaurus#memberNext>")
      return [subject.object_for("<http://www.assero.co.uk/Thesaurus#item>")] if object.nil?
      [subject.object_for("<http://www.assero.co.uk/Thesaurus#item>")] + subset_list(object, depth + 1)  
    end

    def classifications(uris)
      results = []
      uris.each do |uri|
        subject = @subjects[uri]
        classified_as = subject.object_for("<http://www.assero.co.uk/ISO11179Concepts#classifiedAs>")
        contexts = subject.objects_for("<http://www.assero.co.uk/ISO11179Concepts#context>")
        results += contexts.map{|x| "#{classified_as}.#{x}"}
      end
      results
    end

    def custom(uris)
      results = []
      uris.each do |uri|
        subject = @subjects[uri]
        custom_value = subject.object_for("<http://www.assero.co.uk/ISO11179Concepts#value>")
        contexts = subject.objects_for("<http://www.assero.co.uk/ISO11179Concepts#context>")
        results += contexts.map{|x| "#{custom_value}.#{x}"}
      end
      results
    end

  end
  
  class Subject

    def initialize 
      @triples = []
    end

    def add(triple)
      @triples << triple
    end

    def is_subset?
      has_predicate?("<http://www.assero.co.uk/Thesaurus#isOrdered>")
    end

    def is_ranked?
      has_predicate?("<http://www.assero.co.uk/Thesaurus#isRanked>")
    end

    def is_custom?
      rdf_type == "<http://www.assero.co.uk/ISO11179Concepts#CustomProperty>"
    end

    def is_classification?
      rdf_type == "<http://www.assero.co.uk/ISO11179Concepts#Classification>"
    end

    def ignore?
      rdf_type == "<http://www.assero.co.uk/Thesaurus#Subset>" || 
      rdf_type == "<http://www.assero.co.uk/Thesaurus#SubsetMember>" || 
      rdf_type == "<http://www.assero.co.uk/Thesaurus#RankedCollection>" || 
      rdf_type == "<http://www.assero.co.uk/Thesaurus#RankedMember>" || 
      rdf_type == "<http://www.assero.co.uk/ISO11179Concepts#Classification>" ||
      rdf_type == "<http://www.assero.co.uk/ISO11179Concepts#CustomProperty>"
    end

    def rdf_type
      object_for("<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>")
    end

    def object_for(predicate)
      items = @triples.select{|x| x[:predicate] == predicate}
      return items.first[:object] if items.count == 1
      return nil
    end

    def objects_for(predicate)
      @triples.select{|x| x[:predicate] == predicate}.map{|y| y[:object]}
    end

  private

    def has_predicate?(predicate)
      items = @triples.select{|x| x[:predicate] == predicate}
      items.any?
    end

  end

end