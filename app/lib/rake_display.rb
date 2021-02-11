# Rake Display. Simple Module for Terminal Display. 
#  To only be used for rake tasks.
#
# @author Dave Iberson-Hurst
# @since 3.9.0
module RakeDisplay

  # Display title
  def display_title(text)
    puts ""
    puts ""
    puts "#{text}"
    puts "=" * text.length
    puts ""
  end

  # Format results as a simple table
  def display_results(title, items, labels, widths=[])
    display_title(title)
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

end