# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your wagon's version:
require "hitobito_sbv/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "hitobito_sbv"
  s.version = HitobitoSbv::VERSION
  s.authors = ["Roland Studer"]
  s.email = ["roland@hitobito.com"]
  # s.homepage    = 'TODO'
  s.summary = "Schweizer Blasmusikverband"
  s.description = "Structure and additonal features for hitobito of Schweizer Blasmusikverband"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]

  s.add_dependency "aasm", "~> 5.0"
end
