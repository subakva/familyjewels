# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "family_jewels/version"

Gem::Specification.new do |s|
  s.name        = "familyjewels"
  s.version     = FamilyJewels::VERSION
  s.authors     = ["Jason Wadsworth"]
  s.email       = ["jdwadsworth@gmail.com"]
  s.homepage    = "http://github.com/subakva/familyjewels"
  s.summary     = %q{Build Private Gems}
  s.description = %q{Tools for building and publishing private and customized Ruby gems}

  s.rubyforge_project = "familyjewels"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rcov"
  s.add_runtime_dependency "bundler", "~> 1.0.0"
  s.add_runtime_dependency "thor", "~> 0.14.0"
end
