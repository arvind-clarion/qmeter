module Qmeter
  class Railtie < Rails::Railtie
    ### @arvind : Dule to this rake task is running two times
    # rake_tasks do
    #   spec = Gem::Specification.find_by_name 'qmeter'
    #    load "#{spec.gem_dir}/lib/tasks/qmeter.rake"
    # end
  end
end
