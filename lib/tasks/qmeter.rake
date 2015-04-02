require 'erb'

namespace :qmeter do
  desc "Run Qmeter"
  task :run do
  	thresholds = {}
  	thresholds['security_warnings'] = 1
  	thresholds['rails_best_practices'] = 50
  	thresholds['flog_complexity'] = 5
  	thresholds['stats_ratio'] = 0.0

		# obj = Qmeter::Reporter.new thresholds
		# obj.generate_brakeman_report

		extend Qmeter
		self.initialize_thresholds(thresholds)
		self.generate_final_report
		self.save_report
  end
end
