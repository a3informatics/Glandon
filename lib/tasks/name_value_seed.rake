namespace :name_value do
  desc "Name Value Seed"
  task :seed => :environment do
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "3600")
    NameValue.create(name: "thesaurus_child_identifier", value: "100000")
  end
end
