require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

task default: :test

namespace :test do
  RuboCop::RakeTask.new

  task :opts do
    ENV["TESTOPTS"] = "--verbose"
  end

  desc "Run tests"
  task :specs do |t|
    Rake::TestTask.new(t.name) do |tt|
      tt.libs << "."
      tt.test_files = Dir.glob("test/*.rb")
      tt.warning = false
    end
  end

  desc "Run tests with verbose output"
  task verbose: %i[opts test]
end

desc "Run test suite"
task test: ["test:specs", "test:rubocop"]
