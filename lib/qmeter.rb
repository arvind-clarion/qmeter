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
		collect_metric_fu_details
  	collect_brakeman_details
  	@app_root = Rails.root
  	get_previour_result
  	choose_color
	end

	def save_report
		# Save report data into the CSV
		flag = false
		flag = File.file?("#{Rails.root}/summary_report.csv")
		CSV.open("#{Rails.root}/summary_report.csv", "a") do |csv|
			# csv << ['flog','stats','rails_best_practices','warnings', 'timestamp'] if flag == false
		  csv << [@flog_info.first['flog'].to_f, @stats_info.first['stats'].to_f, @rails_best_practices_info.first['rails_best_practices'], @brakeman_warnings.count, Time.now.strftime("%d/%m")]
		end
	end

	def get_previour_result
		# Get previous report data
		@previous_reports = CSV.read("#{Rails.root}/summary_report.csv").last(4) if File.file?("#{Rails.root}/summary_report.csv")
	end

	def choose_color
		# Check threashhold
    if @brakeman_warnings.count > @security_warnings_max
      @brakeman_warnings_rgy = 'background-color:#D00000;'
    elsif @brakeman_warnings.count > @security_warnings_min && @brakeman_warnings.count < @security_warnings_max
      @brakeman_warnings_rgy = 'background-color:yellow;'
    else
      @brakeman_warnings_rgy = 'background-color:#006633;'
    end

    if @rails_best_practices_info.first['rails_best_practices'] > @rails_best_practices_max
      @rails_best_practices_rgy = 'background-color:#D00000;'
    elsif @rails_best_practices_info.first['rails_best_practices'] > @rails_best_practices_min && @rails_best_practices_info.first['rails_best_practices'] < @rails_best_practices_max
      @rails_best_practices_rgy = 'background-color:yellow;'
    else
      @rails_best_practices_rgy = 'background-color:#006633;'
    end

    if @flog_info.first['flog'] > @flog_complexity_max
      @flog_rgy = 'background-color:#D00000;'
    elsif @flog_info.first['flog'] > @flog_complexity_min && @flog_info.first['flog'] < @flog_complexity_max
      @flog_rgy = 'background-color:yellow;'
    else
      @flog_rgy = 'background-color:#006633;'
    end

    if @stats_info.first['stats'] > @stats_ratio_max
      @stats_rgy = 'background-color:#D00000;'
    elsif @stats_info.first['stats'] > @stats_ratio_min && @stats_info.first['stats'] < @stats_ratio_max
      @stats_rgy = 'background-color:yellow;'
    else
      @stats_rgy = 'background-color:#006633;'
    end
	end
end
