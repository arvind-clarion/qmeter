require "qmeter/version"
require 'qmeter/railtie' if defined?(Rails)
require "csv"
require "qmeter/engine"

module Qmeter
	def initialize_thresholds(thresholds)
		@security_warnings = thresholds['security_warnings']
		@rails_best_practices = thresholds['rails_best_practices']
		@flog_complexity = thresholds['flog_complexity']
		@stats_ratio = thresholds['stats_ratio']
	end

  def collect_brakeman_details
  	# Breakman source file
		file = File.read("#{Rails.root}/report.json")
		data_hash = JSON.parse(file)

	  # Create an array of all warnings
	  @brakeman_warnings = []
	  data_hash['warnings'].each do |warning|
	  	hash = {}
	  	hash['warning_type'] = warning['warning_type']
	  	hash['message'] = warning['message']
	  	hash['file'] = warning['file']
	  	@brakeman_warnings.push(hash)
	  end
	end

	def collect_metric_fu_details
	  # parsing metric_fu report from .yml file
	  @surveys = YAML.load(ERB.new(File.read("#{Rails.root}/tmp/metric_fu/report.yml")).result)
    @matric_fu_info = []

    @surveys.each do |survey|
    	unless survey.blank?
	      case survey[0]
				when :flog
	      	hash = {}
					hash['flog'] = survey[1][:average].round(1)
					@matric_fu_info.push(hash)
    			p "===== From #{survey[0]} ====="
				when :stats
					hash = {}
					hash['stats'] = survey[1][:code_to_test_ratio]
					hash['codeLOC'] = survey[1][:codeLOC]
					hash['testLOC'] = survey[1][:testLOC]
					@matric_fu_info.push(hash) 
					p "===== From #{survey[0]} ====="
			  when :rails_best_practices
			  	hash = {}
			  	hash['rails_best_practices'] = survey[1][:total].first.gsub(/[^\d]/, '').to_i
			  	@matric_fu_info.push(hash)
			  	p "===== From #{survey[0]} ====="
				end
			end
    end
    @flog_info = @matric_fu_info.select{|d| d.keys.first == 'flog'}
  	@stats_info = @matric_fu_info.select{|d| d.keys.first == 'stats'}
  	@rails_best_practices_info = @matric_fu_info.select{|d| d.keys.first == 'rails_best_practices'}
	end

  def generate_final_report
  # 	spec = Gem::Specification.find_by_name 'qmeter'
		# erb_file = "/#{spec.gem_dir}/lib/qmeter/templates/summary_report.html.erb"
		# html_file = File.basename(erb_file, '.erb') 
		# erb_str = File.read(erb_file)

		p "===== Collecting data from metric_fu_report report ====="
		collect_metric_fu_details

  	p "===== Collecting data from brakeman report ====="
  	collect_brakeman_details
  	
  	@app_root = Rails.root

  	p "===== Collecting previous reports ====="
  	get_previour_result

	 #  begin
		# 	renderer = ERB.new(erb_str)
		# 	result = renderer.result()

		# 	File.open(html_file, 'w') do |f|
		# 	  f.write(result)
		# 	end
		# rescue StandardError => e
	 #  	p e.message
	 #  	p e.backtrace
	 #  end
	end

	def save_report
		flag = false
		flag = File.file?("#{Rails.root}/summary_report.csv")
		CSV.open("#{Rails.root}/summary_report.csv", "a") do |csv|
			csv << ['flog','stats','rails_best_practices','warnings', 'timestamp'] if flag == false
		  csv << [@flog_info.first['flog'], @stats_info.first['stats'], @rails_best_practices_info.first['rails_best_practices'], @brakeman_warnings.count, Time.now]
		end
	end

	def get_previour_result
		@previous_reports = CSV.read("#{Rails.root}/summary_report.csv") if File.file?("#{Rails.root}/summary_report.csv")
	end
end
