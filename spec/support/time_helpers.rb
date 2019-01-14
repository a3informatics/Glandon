module TimeHelpers

  def time_now(text)
    puts "#{Time.now()}: #{text}"
  end

  def timer_start
    @start = Time.now()
  end

  def timer_stop(text)
    elapsed_time = (Time.now() - @start)
    puts "#{text}: #{elapsed_time.round(2)} seconds"
  end


end