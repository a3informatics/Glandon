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

end