#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "Load bt in a pry or irb session (alias `rake c`)"
task :console do
  if system("which pry")
    repl = "pry"
  else
    repl = "irb"
  end

  sh "#{repl} -r'bundler/setup' -rbt"
end
task :c => :console
