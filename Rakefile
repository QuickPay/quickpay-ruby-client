require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

RuboCop::RakeTask.new

task :opts do
  ENV["TESTOPTS"] = "--verbose"
end

desc "Run tests with verbose output"
task "test:verbose" => %i[opts test]

desc "Run tests"
task :test do |t|
  Rake::TestTask.new(t.name) do |tt|
    tt.libs << "."
    tt.test_files = Dir.glob("test/*.rb")
    tt.warning = false
  end
end

task default: %i[test rubocop]
