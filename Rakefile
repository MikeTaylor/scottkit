require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "scottkit"
    gem.license = 'GPL-2.0'
    gem.summary = "Toolkit for Scott Adams-format adventure games"
    gem.description = "ScottKit is a toolkit for compiling, decompiling and playing adventure games in the Scott Adams format."
    gem.email = "mike@miketaylor.org.uk"
    gem.homepage = "http://github.com/MikeTaylor/scottkit"
    gem.author = "Mike Taylor"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    # No version, date or files -- I guess jeweler takes care of those
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "scottkit #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :regenerate do
  sh "cd games/test && make rebuild"
  sh "cd games/test/adams && make rebuild"
end
