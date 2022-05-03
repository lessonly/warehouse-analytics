require File.expand_path('../lib/warehouse/analytics/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'analytics-ruby'
  spec.version = Warehouse::Analytics::VERSION
  spec.files = Dir.glob("{lib,bin}/**/*")
  spec.require_paths = ['lib']
  spec.bindir = 'bin'
  spec.executables = ['analytics']
  spec.summary = 'Warehouse.io analytics library'
  spec.description = 'The Warehouse.io ruby analytics library'
  spec.authors = ['Warehouse.io']
  spec.email = 'friends@warehouse.io'
  spec.homepage = 'https://github.com/warehouseio/analytics-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.0'

  # Used in the executable testing script
  spec.add_development_dependency 'commander', '~> 4.4'

  # Used in specs
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'tzinfo', '1.2.1'
  spec.add_development_dependency 'activesupport', '~> 4.1.11'
  spec.add_development_dependency 'oj', '~> 3.6.2'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'
end
