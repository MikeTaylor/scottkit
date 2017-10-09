#!/usr/local/bin/ruby -w

# Run as: echo Bart Lisa | ./withio_test.rb && echo == && cat /tmp/xcv
# Expecting the output:
#	first line is 'Bart Lisa'
#	saved line 'Eric'
#	died in withIO: divided by 0
#	saved line was 'Eric'
#	==
#	first line was 'Bart Lisa'
#	oldout is of class IO

require 'stringio'
require 'scottkit/withio'

saved = nil
begin
  line = gets
  puts "first line is '#{line.chomp}'"
  withIO(StringIO.new("Eric\nthe"), File.new("/tmp/xcv", "w")) do
    |oldin, oldout|
    puts "first line was '#{line.chomp}'"
    puts "oldout is of class #{oldout.class}"
    saved = gets
    oldout.puts "saved line '#{saved.chomp}'"
    puts 1/0
  end
rescue Exception => e
  puts "died in withIO: #{e}"
end
puts "saved line was '#{saved.chomp}'"
