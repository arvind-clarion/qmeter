require 'erb'
require 'terminal-table'

namespace :qmeter do
  desc "Run brakeman and metric_fu to generate report of code"

  ### @arvind: This will run command to generate brakeman and matric fu report ###
  task :generate_report do
    puts "*** run brakeman ***"
    system "brakeman -o report.html -o report.json"

    puts "*** run metric_fu ***"
    system "metric_fu --out #{Rails.root}/public/metric_fu "

  end

  ### *** ###
  task :run do
    ### @arvind: This always executes the task, but it doesn't execute its dependencies
    Rake::Task["qmeter:generate_report"].execute
    ### *** ###
    extend Qmeter
    self.generate_final_report
    puts "======= Saving Current Analysis Details ======="
    self.save_report

    rows = []
    rows << ['Security Warning', @warnings_count]
    rows << ['Flog', @flog_average_complexity]
    rows << ['Stats', @stats_code_to_test_ratio]
    rows << ['Rails Best Practices', @rails_best_practices_total]
    table = Terminal::Table.new :title => "Qmeter Analysis", :headings => ['Type', 'Number'], :rows => rows, :style => {:width => 80}
    puts table
    puts "======= Please visit localhost:3000/qmeter for detailed report ======="
  end
end
