# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "--format pretty"
end

task default: [:spec, :cucumber]

desc "Run all tests (RSpec and Cucumber)"
task test: [:spec, :cucumber]

desc "Generate YARD documentation"
task :doc do
  sh "yard doc"
end
