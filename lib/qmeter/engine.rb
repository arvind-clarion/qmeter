module Qmeter
  class Engine < Rails::Engine
    ### @arvind : Added css and js file to assets as it require for qmeter page ###
    initializer "qmeter.assets.precompile" do |app|
      app.config.assets.precompile += %w( qmeter/qmeter.css  qmeter/jquery-v1.11.2.js qmeter/qmeter.js)
    end
  end
end