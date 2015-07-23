require 'erb'
require 'qmeter/string'
require 'terminal-table'

namespace :qmeter do
  desc "Run brakeman and metric_fu to generate report of code"
  ######@sourabh: copy the jshint file from gem cogif to application config #######
   source = File.join(Gem.loaded_specs["qmeter"].full_gem_path, "config", "jshint.yml")
    target = File.join(Rails.root, "config", "jshint.yml")
    FileUtils.cp_r source, target

  ### @arvind: This will run command to generate brakeman and matric fu report ###
  task :generate_report do
    puts "*** run brakeman ***"
    system "brakeman -o report.html -o report.json"

    puts "*** run metric_fu ***"
    system "metric_fu --out #{Rails.root}/public/metric_fu "

    puts "-----JAVASCRIPT Erorrs----------"
    system "jshint"

  end

  task :add_command_in_post_commit do
    ### @arvind:  Asked user to add rake command inside git post commit file , Task will run in each eommit
    STDOUT.puts "Write Y to add rake qmeter:run command to 'post commit', it will run when you commit the code".reverse_color
    input = STDIN.gets.strip
    if input == 'y'
      File.open('.git/hooks/post-commit', 'a') do |f|
        f.puts "rake qmeter:run"
      end
      system "chmod +x .git/hooks/post-commit"
    else
      STDOUT.puts "You can add it in next time"
    end
  end

  ### *** ###
  task :run do
    ### @arvind:  this will check git post commit has rake command or not
    if File.file?('.git/hooks/post-commit')
      file =  File.read(".git/hooks/post-commit").include?('rake qmeter:run')
      if !file =  File.read(".git/hooks/post-commit").include?('rake qmeter:run')
        Rake::Task["qmeter:add_command_in_post_commit"].execute
      end
    else
      Rake::Task["qmeter:add_command_in_post_commit"].execute
    end

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

  # This will append Files/Folders in .gitignore file
  task :gitignore do
    add_to_ignore("qmeter.csv")
    add_to_ignore("report.json")
    add_to_ignore("report.html")
    add_to_ignore("public/metric_fu")
  end

  def add_to_ignore(file_folder)
    resourse = file_folder.to_s
    File.read('.gitignore').include?(resourse) ? "Already there" : (file = File.open('.gitignore', 'a'); file.puts(resourse); file.close_write; "Added to .gitignore")
  end
end
