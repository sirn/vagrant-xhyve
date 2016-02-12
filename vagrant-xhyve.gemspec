# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-xhyve/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-xhyve'
  spec.version       = VagrantPlugins::Xhyve::VERSION
  spec.authors       = ['Kridsada Thanabulpong']
  spec.email         = ['sirn@ogsite.net']

  spec.description   = %q{Enables Vagrant to manage Xhyve instances.}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/sirn/vagrant-xhyve'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions    = %w[ext/vagrant-xhyve/support/extconf.rb]

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rake-compiler', '~> 0.9.5'
  spec.add_development_dependency 'racc', '~> 1.4.14'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
