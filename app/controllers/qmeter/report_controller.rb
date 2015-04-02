module Qmeter
  class ReportController < ::ApplicationController
  	
    def index
    	thresholds = {}
	  	thresholds['security_warnings'] = 1
	  	thresholds['rails_best_practices'] = 50
	  	thresholds['flog_complexity'] = 5
	  	thresholds['stats_ratio'] = 0.0

			extend Qmeter
			self.initialize_thresholds(thresholds)
			self.generate_final_report
			self.save_report
    	render layout: false
    end
  end
end