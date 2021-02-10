namespace :triple_store do

  desc "Draft Updates"

  # Format results as a simple table
  def display_results(items, labels, widths=[])
    results = [labels]
    results += items.map { |x| x.values }
    max_lengths = results[0].map { |x| x.length }
    unless widths.empty?
      results.each_with_index do |x, j|
        x.each_with_index do |e, i|
          next if widths[i] == 0 
          results[j][i]= "#{e.to_s[0..widths[i]-1]}[...]" if e.to_s.length > widths[i]
        end
      end
    end
    results.each do |x|
      x.each_with_index do |e, i|
        s = e.to_s.length
        max_lengths[i] = s if s > max_lengths[i]
      end
    end
    format = max_lengths.map {|y| "%#{y}s"}.join(" " * 3)
    puts format % results[0]
    puts format % max_lengths.map { |x| "-" * x }
    results[1..-1].each do |x| 
      puts format % x 
    end
    puts "\n\n"
  end

  # Identify Code Lists
  def identify_code_lists(short_name)
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v ?i ?sv (COUNT(?x) as ?c) WHERE 
      {
        ?s rdf:type #{Thesaurus::ManagedConcept.rdf_type.to_ref} .
        ?s isoT:hasState ?st .
        ?s isoT:hasIdentifier ?si .
        ?si isoI:hasScope/isoI:shortName "#{short_name}" .
        ?s isoC:label ?l .
        ?si isoI:version ?v .
        ?si isoI:identifier ?i .
        ?si isoI:semanticVersion ?sv .
        ?s th:narrower ?x
      } GROUP BY ?s ?l ?v ?i ?sv ORDER BY ?l ?v 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:s, :l, :v, :i, :sv, :c])
    display_results(items, ["Uri", "Label", "Ver", "Identifier", "Semantic Ver", "Items"], [0, 100, 0, 0, 0, 0])
    items
  end

  # Actual rake task
  task :ct_summary => :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    abort("A short name$ should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a short name) should be supplied") unless ARGV.count == 2
    actions = identify_code_lists(ARGV[1])
  end

end