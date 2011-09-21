require "bundler/gem_tasks"

require 'rspec/core/rake_task'

desc "Run integration examples"
RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = './integration/**/*_spec.rb'
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
