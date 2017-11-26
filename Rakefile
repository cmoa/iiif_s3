require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
  t.stats_options = ['--list-undoc']         # optional
end

desc "Clear the screen"
task :cls do
  puts "Clearing the Screen \033c"
end

task :full do
  ENV["TEST_INTERNET_CONNECTIVITY"] = "yes"
  ENV["SKIP_EXPENSIVE_TESTS"] = nil
end

task :default => [:cls, :spec, :yard]

task :full_test => [:full, :default]