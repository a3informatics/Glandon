namespace :r3_1_0 do

  desc "R3.1.0 Data Update"

  # Check for success?
  def r3_1_0_data_success?(base)
    Sparql::Utility.new.ask?("?s th:refersTo ?o", [:th])
  end

  # Should we migrate?
  def r3_1_0_data_migrate?
    # Must not find any
    !Sparql::Utility.new.ask?("?s th:refersTo ?o", [:th])
  end

  # Execute migration
  def r3_1_0_data_execute
    
    # Base triple count
    step = 0
    base = Sparql::Utility.new.triple_count

    # Thesaurus extensions fix triples. Will only happen if file load raised no errors
    puts "Update data ..."
    step = 1
    sparql = Sparql::Update.new
    sparql_update = %Q{
      INSERT 
      {
        ?s th:refersTo ?cli
      }
      WHERE 
      {
        {
          ?s th:extends ?ext .
          ?s th:narrower ?cli .
          ?cli ^th:narrower ?par . 
          FILTER (?par != ?s)
        } 
        UNION
        {
          ?s th:subsets ?sub .
          ?s th:narrower ?cli .          
        }
      }         
    }
    sparql.sparql_update(sparql_update, "", [:th, :bo])

    # Checks and finish
    abort("Data migration not succesful, checks failed") unless r3_1_0_data_success?(base)
    puts "Data migration succesful"

  rescue => e
    msg = "Data migration error, step: #{step}"
    abort("#{msg}\n\n#{e}\n\n#{e.backtrace}")
  end

  # Actual rake task
  task :data => :environment do
    abort("Data migration not required") unless r3_1_0_data_migrate?
    r3_1_0_data_execute
  end

end