module Qmeter
  class Railtie < Rails::Railtie
  	rake_tasks do
    	spec = Gem::Specification.find_by_name 'qmeter'
			load "#{spec.gem_dir}/lib/tasks/qmeter.rake"
  	end
  end
end