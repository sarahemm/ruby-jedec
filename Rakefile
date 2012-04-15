require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "jedec"
    gemspec.summary = "Library for dealing with JEDEC fuse files."
    gemspec.description = "Ruby/Jedec is a Ruby library that provides a class to read and write JEDEC fuse data files, used for programmable logic devices."
    gemspec.email = "ruby-jedec@sen.cx"
    gemspec.homepage = 'http://github.com/sarahemm/ruby-jedec'
    gemspec.authors = ['sen']
    gemspec.has_rdoc = false
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

task :clean do
  rm_rf(Dir['doc'], :verbose => true)
  rm_rf(Dir['pkg'], :verbose => true)
end