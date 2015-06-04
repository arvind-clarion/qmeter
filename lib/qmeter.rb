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
    file = check_and_assign_file_path('report.json')
    if  file.present?
      data_hash = JSON.parse(file)
      ### @arvind: change array to hash and check it contain warnings or not
      if data_hash.present? && data_hash[0].has_key?('warnings')
        warning_type = data_hash['warnings'].map {|a| a = a['warning_type'] if a.has_key? 'warning_type'}
        @brakeman_warnings = Hash.new(0)
        warning_type.each do |v|
          @brakeman_warnings[v] += 1
        end
        @warnings_count = data_hash['warnings'].count
      end
    end
  end

  def collect_metric_fu_details
  # parsing metric_fu report from .yml file
    file = check_and_assign_file_path('tmp/metric_fu/report.yml')
    if file.present?
      @surveys  = YAML.load(ERB.new(file).result)
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
  end

  def generate_final_report
    collect_metric_fu_details
    collect_brakeman_details
    @app_root = Rails.root
    get_previour_result
  end

  def save_report
    # Save report data into the CSV
    ### Hide this because we are not using this currently
    #flag = false
    #flag = File.file?("#{Rails.root}/qmeter.csv")
    file = check_and_assign_file_path('qmeter.csv')
    if file
      CSV.open("#{Rails.root}/qmeter.csv", "a") do |csv|
        #csv << ['flog','stats','rails_best_practices','warnings', 'timestamp'] if flag == false
        sha = `git rev-parse HEAD`
        csv << [@flog_average_complexity, @stats_code_to_test_ratio, @rails_best_practices_total, @warnings_count, sha]
      end
    end
  end

  def get_previour_result
    # Get previous report data
    @previous_reports = CSV.read("#{Rails.root}/qmeter.csv").last(4) if check_and_assign_file_path("qmeter.csv")
  end

  def choose_color
    # Check threashhold
    ### @arvind: set color to the variables ###
    @brakeman_warnings_rgy = set_color(@warnings_count, @security_warnings_max,  @security_warnings_min)
    @rails_best_practices_rgy = set_color(@rails_best_practices_total, @rails_best_practices_max, @rails_best_practices_min)
    @flog_rgy = set_color(@flog_average_complexity, @flog_complexity_max, @flog_complexity_min)
    @stats_rgy = set_color(@stats_code_to_test_ratio, @stats_ratio_max, @stats_ratio_min )
  end

  ### @arvind: method to check file is exist or not ###
  def check_and_assign_file_path(path)
    file = "#{Rails.root}/#{path}"
    File.exist?(file) ? File.read(path)  : nil
  end

  ### @arvind: send proper color according to data ###
  def set_color(count, max, min)
    if count.present? && count > max
      'background-color:#D00000;'
    elsif count.present? && count > min && count < max
      'background-color:yellow;'
    else
      'background-color:#006633;'
    end
  end
end
