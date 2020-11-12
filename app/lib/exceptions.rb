# Manages the exceptions raised by the application
#
# @author Dave Iberson-Hurst
# @since 0.0.1
# @deprecated Use the Errors class
module Exceptions

  class DestroyError < StandardError
  	attr_reader :message
  	def initialize(message)
   		super
   		@message = message
  	end
	end

	class UpdateError < StandardError
  	attr_reader :message
  	def initialize(message)
   		super
   		@message = message
  	end  	
	end

	class CreateError < StandardError
  	attr_reader :message
  	def initialize(message)
   		super
   		@message = message
  	end
	end

  class TripleError < StandardError  
    attr_reader :message
    def initialize(message)
      super
      @message = message
    end
  end

  class MultipleOwnerError < StandardError  
    attr_reader :message
    def initialize(message)
      super
      @message = message
    end
  end

  class NotFoundError < StandardError  
    attr_reader :message
    def initialize(message)
      super
      @message = message
    end
  end

  class ApplicationLogicError < StandardError  
    #attr_reader :message
    #def initialize(message)
    #  super
    #  @message = message
    #end
  end

end