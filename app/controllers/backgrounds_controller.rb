class BackgroundsController < ApplicationController

	def index
	end

	def running
		#jobs = Background.where(complete: false).find_each
        jobs = Background.all
        results = {}
	    results[:data] = []
	    jobs.each do |job|
	      results[:data] << job
	    end
	    render :json => results, :status => 200
	end

	def clear
		Background.destroy_all
		redirect_to backgrounds_path
	end

end
