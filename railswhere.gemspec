# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "railswhere"
  s.version     = "0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tim Harper"]
  s.email       = ["timcharper@gmail.com"]
  s.homepage    = "http://tim.theenchanter.com/"
  s.summary     = "Easily generate SQL statements"
  s.description = "Obligatory description when the summary suits."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "activerecord", "> 3.0 "
  s.add_development_dependency "sqlite3-ruby"
  s.add_development_dependency "rspec", "2.5.0"
  s.add_development_dependency "ruby-debug"

  s.files        = Dir.glob("lib/**/*") + %w(MIT-LICENSE)
  s.executables  = []
  s.require_path = 'lib'
end
