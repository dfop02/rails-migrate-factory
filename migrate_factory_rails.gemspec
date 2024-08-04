# frozen_string_literal: true

require_relative 'lib/migrate_factory_rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'migrate_factory_rails'
  spec.version     = MigrateFactoryRails::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Diogo Fernandes']
  spec.email       = ['diogofernandesop@gmail.com']

  spec.summary     = 'Rebuild your Rails migrations'
  spec.description = 'Completely rebuild your migrations to agilize setup and simplify schema.'
  spec.homepage    = 'https://github.com/dfop02/migrate_factory_rails'
  spec.license     = 'MIT'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{spec.homepage}/issues",
    'wiki_uri'          => "#{spec.homepage}/wiki",
    'changelog_uri'     => "#{spec.homepage}/blob/#{spec.version}/Changelog.md",
    'homepage_uri'      => spec.homepage,
    'documentation_uri' => spec.homepage,
    'source_code_uri'   => spec.homepage
  }

  spec.files            = Dir['lib/**/*']
  spec.rdoc_options     = ['--charset=UTF-8']
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE']
  spec.require_path     = 'lib'
  spec.bindir           = 'exe'
  spec.executables      = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths    = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.add_runtime_dependency 'rails', '>= 4.0', '<= 7.1'

  spec.add_development_dependency 'rake'
end
