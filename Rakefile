require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/extensiontask'

SUPPORT_DIR = 'lib/vagrant-xhyve/support'.freeze
DHCPD_PARSER = "#{SUPPORT_DIR}/dhcpd_leases.rb".freeze

Rake::ExtensionTask.new('vmnet_mac') do |ext|
  ext.ext_dir = 'ext/vagrant-xhyve/support'
  ext.lib_dir = SUPPORT_DIR
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

file DHCPD_PARSER => "#{SUPPORT_DIR}/dhcpd_leases.y" do |t|
  sh "racc -o #{t.name} #{t.prerequisites.first}"
end

Rake::Task['compile'].prerequisites << DHCPD_PARSER
task :default => :test
