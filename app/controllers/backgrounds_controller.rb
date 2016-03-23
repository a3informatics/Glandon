class BackgroundsController < ApplicationController

	def index
		authorize Background
  end

	def running
		authorize Background
    jobs = Background.all
    results = {}
    results[:data] = []
    jobs.each do |job|
      results[:data] << job
    end
    render :json => results, :status => 200
	end

	def clear
		authorize Background
    jobs = Background.where(complete: true).find_each
		jobs.each do |job|
			job.destroy
		end
		redirect_to backgrounds_path
	end

end
