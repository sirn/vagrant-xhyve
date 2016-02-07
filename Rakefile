require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/extensiontask'

LIB_DIR = 'lib/vagrant-xhyve'.freeze
DHCPD_PARSER = "#{LIB_DIR}/dhcpd_leases_parser.rb".freeze

Rake::ExtensionTask.new('vmnet_mac') do |ext|
  ext.ext_dir = 'ext/vagrant-xhyve'
  ext.lib_dir = LIB_DIR
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

file DHCPD_PARSER => "#{LIB_DIR}/dhcpd_leases_parser.y" do |t|
  sh "racc -o #{t.name} #{t.prerequisites.first}"
end

Rake::Task['compile'].prerequisites << DHCPD_PARSER
task :default => :test
