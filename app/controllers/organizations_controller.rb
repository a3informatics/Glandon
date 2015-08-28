class OrganizationsController < ApplicationController

  before_action :authenticate_user!
  
  def index
    @organizations = Organization.all
  end
  
  def new
    @organization = Organization.new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show
  end
  
end