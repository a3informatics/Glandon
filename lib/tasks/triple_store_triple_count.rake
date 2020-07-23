namespace :triple_store do

  desc "Triple Store Triple Count"

  # Execute task
  def triple_store_triple_count_execute
    puts "Triple count: #{Sparql::Utility.new.triple_count}"
  rescue => e
    msg = "Triple Store triple count error."
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :triple_count => :environment do
    triple_store_triple_count_execute
  end

end