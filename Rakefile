require "bundler/gem_tasks"

require 'rspec/core/rake_task'

desc "Run integration examples"
task :integration do
  puts "Run: integration/bin/test"
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb'
end

desc "Run all examples with rcov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features,spec/*"]
end
