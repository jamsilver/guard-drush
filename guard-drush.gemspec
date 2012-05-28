# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "guard/drush/version"

Gem::Specification.new do |s|
  s.name        = "guard-drush"
  s.version     = Guard::DrushVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James Silver"]
  s.email       = ["james.silver@computerminds.co.uk"]
  s.homepage    = "http://rubygems.org/gems/guard-drush"
  s.summary     = 'Guard gem for Drush'
  s.description = 'Guard Drush automatically runs drush in your Drupal site.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = "guard-drush"

  s.add_dependency 'guard', '>= 0.10.0'

  s.add_development_dependency 'bundler', '~> 1.0'

  s.files         = Dir.glob('{lib}/**/*') + %w[README.md]
  s.require_path = "lib"
end
