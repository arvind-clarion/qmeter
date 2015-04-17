require "qmeter/version"
require 'qmeter/railtie' if defined?(Rails)
require "csv"
require "qmeter/engine"

module Qmeter
	def initialize_thresholds(thresholds)
		# Initialize threshold values
		@security_warnings_min = thresholds['security_warnings_min']
		@security_warnings_max = thresholds['security_warnings_max']

		@rails_best_practices_min = thresholds['rails_best_practices_min']
		@rails_best_practices_max = thresholds['rails_best_practices_max']

		@flog_complexity_min = thresholds['flog_complexity_min']
		@flog_complexity_max = thresholds['flog_complexity_max']

		@stats_ratio_min = thresholds['stats_ratio_min']
		@stats_ratio_max = thresholds['stats_ratio_max']
	end

  def collect_brakeman_details
  	# Breakman source file
		file = File.read("#{Rails.root}/report.json")
		data_hash = JSON.parse(file)

	  warning_type = data_hash['warnings'].map {|a| a = a['warning_type']}
	  @brakeman_warnings = Hash.new(0)
	  warning_type.each do |v|
		  @brakeman_warnings[v] += 1
		end
		@warnings_count = data_hash['warnings'].count
	end

	def collect_metric_fu_details
	  # parsing metric_fu report from .yml file
	  @surveys = YAML.load(ERB.new(File.read("#{Rails.root}/tmp/metric_fu/report.yml")).result)

    @surveys.each do |survey|
    	unless survey.blank?
	      case survey[0]
				when :flog
    			@flog_average_complexity = survey[1][:average].round(1)
				when :stats
					@stats_code_to_test_ratio = survey[1][:code_to_test_ratio]
			  when :rails_best_practices
			  	@rails_best_practices_total = survey[1][:total].first.gsub(/[^\d]/, '').to_i
				end
			end
    end
	end

  def generate_final_report
		collect_metric_fu_details
  	collect_brakeman_details
  	@app_root = Rails.root
  	get_previour_result
	end

	def save_report
		# Save report data into the CSV
		flag = false
		flag = File.file?("#{Rails.root}/qmeter.csv")
		CSV.open("#{Rails.root}/qmeter.csv", "a") do |csv|
			# csv << ['flog','stats','rails_best_practices','warnings', 'timestamp'] if flag == false
	    sha = `git rev-parse HEAD`
		  csv << [@flog_average_complexity, @stats_code_to_test_ratio, @rails_best_practices_total, @warnings_count, sha]
		end
	end

	def get_previour_result
		# Get previous report data
		@previous_reports = CSV.read("#{Rails.root}/qmeter.csv").last(4) if File.file?("#{Rails.root}/qmeter.csv")
	end

	def choose_color
		# Check threashhold
    if @warnings_count > @security_warnings_max
      @brakeman_warnings_rgy = 'background-color:#D00000;'
    elsif @warnings_count > @security_warnings_min && @warnings_count < @security_warnings_max
      @brakeman_warnings_rgy = 'background-color:yellow;'
    else
      @brakeman_warnings_rgy = 'background-color:#006633;'
    end

    if @rails_best_practices_total > @rails_best_practices_max
      @rails_best_practices_rgy = 'background-color:#D00000;'
    elsif @rails_best_practices_total > @rails_best_practices_min && @rails_best_practices_total < @rails_best_practices_max
      @rails_best_practices_rgy = 'background-color:yellow;'
    else
      @rails_best_practices_rgy = 'background-color:#006633;'
    end

    if @flog_average_complexity > @flog_complexity_max
      @flog_rgy = 'background-color:#D00000;'
    elsif @flog_average_complexity > @flog_complexity_min && @flog_average_complexity < @flog_complexity_max
      @flog_rgy = 'background-color:yellow;'
    else
      @flog_rgy = 'background-color:#006633;'
    end

    if @stats_code_to_test_ratio > @stats_ratio_max
      @stats_rgy = 'background-color:#D00000;'
    elsif @stats_code_to_test_ratio > @stats_ratio_min && @stats_code_to_test_ratio < @stats_ratio_max
      @stats_rgy = 'background-color:yellow;'
    else
      @stats_rgy = 'background-color:#006633;'
    end
	end
end
