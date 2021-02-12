# Name Value Read Rake Task
#
# @author Dave Iberson-Hurst
# @since 3.8.0
namespace :name_value do
  desc "Name Value Read"
  task :read => :environment do

    include RakeDisplay

    items = NameValue.all.map { |r| r.attributes.symbolize_keys.slice(:name, :value) }
    display_results("Name Value Table", items, ["Name", "Value"], [0, 0])
  end
end
