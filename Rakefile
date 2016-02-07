require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/extensiontask'

Rake::ExtensionTask.new('vmnet_mac') do |ext|
  ext.ext_dir = 'ext/vagrant-xhyve'
  ext.lib_dir = 'lib/vagrant-xhyve'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test
