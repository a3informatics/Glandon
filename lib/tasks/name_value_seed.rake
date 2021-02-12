# Name Value Seed Rake Task
#
# @author Dave Iberson-Hurst
namespace :name_value do
  desc "Name Value Seed"
  task :seed => :environment do
    
    include RakeDisplay

    # Seed
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "4000")
    NameValue.create(name: "thesaurus_child_identifier", value: "100000")

    # Display
    items = NameValue.all.map { |r| r.attributes.symbolize_keys.slice(:name, :value) }
    display_results("Name Value Table Seeded", items, ["Name", "Value"], [0, 0])

  end
end
