module BackgroundHelpers

  def item_difference(checks, qualifier="")
    status_map = {:~ => :not_present, :- => :no_change, :C => :created, :U => :updated, :D => :deleted}
    checks.each do |check|
      objects = []
      versions.each { |version| objects << yield(version, check[:name], qualifier) }
      objects.each_with_index do |object, index|
        if index != 0
          result = IsoConcept.difference(objects[index - 1], objects[index], {ignore: [:ordinal]})
          extra_1(index, check[:name], status_map[check[:result][index]], result[:status])
          expect(result[:status]).to eq(status_map[check[:result][index]])
          result[:results].each do |k, v|
            diff = extra_1(index, k, !check[:properties][index].include?(k), v[:status] == :no_change)
            extra_2(index, v[:previous], v[:current]) if diff
            expect(v[:status] == :no_change).to eq(!check[:properties][index].include?(k))
          end
        end
      end
    end
  end

  def extra_1(index, name, expected, result)
    return false if !extra_output
    expected == result ? flag = "" : flag = "**********"
    puts "Index: #{index}, Name: #{name}: Expected: #{expected}, Result: #{result} #{flag}"
    return !flag.blank?
  end

  def extra_2(index, previous, current)
    puts "Index: #{index}, P: #{previous}"
    puts "Index: #{index}, C: #{current}"
  end

end