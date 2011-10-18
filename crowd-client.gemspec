# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "crowd-client/version"

Gem::Specification.new do |s|
  s.name        = "crowd-client"
  s.version     = Crowd::Client::VERSION
  s.authors     = ["Paul Nicholson"]
  s.email       = ["paul@webpowerdesign.net"]
  s.homepage    = ""
  s.summary     = %q{Crowd Client Library}
  s.description = %q{A simple rest client for Crowd}

  s.rubyforge_project = "crowd-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"

  s.add_runtime_dependency "faraday", "~> 0.7.5"
  s.add_runtime_dependency "faraday_middleware", "~> 0.7.0"
  s.add_runtime_dependency "patron", "~> 0.4.16"
  s.add_runtime_dependency "json", "~> 1.6.1"
end
