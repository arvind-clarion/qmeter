# Qmeter

Qmeter fetch data from the already generated application reports through brakeman and metric_fu. Before every commit it checks your code quality and gives you the status of some major areas. Based on some thresholds it checks for some major areas like security issues, test coverage and Rails best practices etc.

Also Qmeter has a provision to save report data into CSV and based on the previous report's data it shows up the graphs.

## Installation

Add below line to your Gemfile:

```
gem 'qmeter', :git => 'git://github.com/arvind-clarion/qmeter.git', :group => :development
                    or 
gem 'qmeter', :git => 'git://github.com/arvind-clarion/qmeter.git', tag: 'v1.0'

```

Runtime dependancies

```
brakeman
metric_fu
terminal-table
```

And then execute:

```
  $ bundle
```

## Usage

Ignore files and folders form .gitignore
```
 rake qmeter:gitignore
```

Run Qmeter
```
 rake qmeter:run
```

It's ready to perform now. On every git commit it will check the code quality and saves the result.

To get detailed analysis report visit '/qmeter' 

```
localhost:3000/qmeter
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/qmeter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
