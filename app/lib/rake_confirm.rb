# Rake Display. Simple Module for Terminal Display. 
#  To only be used for rake tasks.
#
# @author Dave Iberson-Hurst
# @since 3.9.1
module RakeConfirm

  # confirm
  def confirm_destructive
    puts "This task is destructive! Are you sure you want to continue? [y/N]"
    input = STDIN.gets.chomp
    return true if input.downcase == "y"
    false
  end

end