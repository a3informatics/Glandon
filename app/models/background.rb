class Background < ApplicationRecord

  has_one :import
  before_destroy :check_for_import

  def check_for_import
    if !self.import.nil?
      errors.add(:base, "cannot delete background job while an import exists")
      throw(:abort)
      #return false
    end
  end

  # Start
  #
  # @param [String] description description of the job
  # @param [String] status the current status
  # @return [void] no return
  def start(description, status)
    self.update(description: description, status: status, complete: false, percentage: 0, started: Time.now())
    yield
  end

  # End
  #
  # @param [String] status the final status
  # @return [void] no return
  def end(status)
    self.update(status: status, percentage: 100, complete: true, completed: Time.now())
  end

  # Exception
  #
  # @param [String] status the final status
  # @param [String] e the exception
  # @return [void] no return
  def exception(status, e)
    self.update(status: "#{status}\nDetails: #{e}.\nBacktrace: #{e.backtrace}", percentage: 100, complete: true, completed: Time.now())    
  end

  # Update
  #
  # @param [String] status the current status
  # @param [Integer] current_percentage the percentage complete
  # @return [void] no return
  def running(status, current_percentage)
    @status = status
    self.update(status: status, percentage: current_percentage)
  end

  # Set Status. Update the status message
  #
  # @return [void] no return
  def set_status
    self.update(status: status)
  end
  
  # Set Range and Total. Set the next range and the total number of items. Will reset the count to zero.
  #
  # @param [Range] range the range
  # @param [Integer] total the ttoal number of items in the range.
  # @return [void] no return
  def set_range_and_total(range, total)
    @range = range
    @total = total
    @count = 0
  end

  # Set Total. Sets the total number of items in a range. Will reset the count to zero.
  #
  # @param [Integer] total the ttoal number of items in the range.
  # @return [void] no return
  def set_total(total)
    @total = total
    @count = 0
  end

  # Set Range. Set the next range. Will reset the count to zero.
  #
  # @param [Range] range the range
  # @return [void] no return
  def set_range(range)
    @range = range
    @count = 0
  end

  # Increment. increment the current count and update the percentage progress.
  #
  # @return [void] no return
  def increment
    @count += 1
    self.update(percentage: calculate_percentage)
  end
  
  # Increment With Status. increment the current count and update the percentage progress and status.
  #
  # @return [void] no return
  def increment_with_status(status)
    @count += 1
    self.update(percentage: calculate_percentage, status: status)
  end
  
  # Get Progress. Get the progress
  #
  # @return [Integer] the current percentage
  def get_progress
    calculate_percentage
  end
	
private

  # Calculate the precentage progress.
  def calculate_percentage
    return (@range.begin.to_f+((@range.size-1).to_f*(@count.to_f/@total.to_f))).round
  end

end
