class BackgroundsController < ApplicationController

	def running
		jobs = Background.all
    results = {}
    results[:data] = []
    jobs.each do |job|
      results[:data] << job
    end
    render :json => results, :status => 200
	end

	def clear
		#Background.destroy_all
		jobs = Background.where(complete: true).find_each
		jobs.each do |job|
			job.destroy
		end
		redirect_to backgrounds_path
	end

end
