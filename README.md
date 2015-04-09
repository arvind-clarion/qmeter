# Qmeter

Qmeter fetch data from the already generated application reports through brakeman and metric_fu. 
Based on some thresholds it checks for some major areas like security issues, test coverage and Rails best practices etc.
Also Qmeter has a provision to save report data into CSV. Based on the previous reports data show it up into the graph.

## Installation

Install other required gems 

```
$ gem install brakeman
$ gem install metric_fu
```

Add below line to your Gemfile:

```
gem 'qmeter', :git => 'git://github.com/rohit-clarion/qmeter.git', :group => :development
```

And then execute:

```
  $ bundle
```

Or install it yourself as:

```
  $ gem install qmeter
```

## Usage

#### qmeter is not yet ready for use, but still you can use it for testing purpose.


Run below commands, also add your root path while running metric_fu command

```
	$ brakeman -o report.html -o report.json
	$ metric_fu --out /path/to/the/app/root/public/metric_fu
```

Run Qmeter

To run Qmeter visit

```
localhost:3000/qmeter
```

TODO:: 

1. Update passing and failing areas conditions into the templates.
2. Make report template more attractive.
3. Make it run the brakeman and metric_fu commands internally instead of manually.
4. Save report details at every commit.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/qmeter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request