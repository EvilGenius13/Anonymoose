require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/unit/*_test.rb', 'test/integration/*_test.rb']
  t.verbose = true
end

task default: :test

desc "Run the app in development mode"
task :dev do
  sh "RACK_ENV=development bundle exec falcon serve --bind http://localhost:9292"
end