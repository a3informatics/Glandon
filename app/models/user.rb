class User < ActiveRecord::Base

	# Constants
  C_CLASS_NAME = "User"

  # Rolify gem extension for roles
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :set_extra

  # Set any extra items we need when a user is created
  def set_extra
  	# Set the reader default role.
    self.add_role :reader
    #ConsoleLogger::log(C_CLASS_NAME,"set_extra","Role set to reader")
  end

end
