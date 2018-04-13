$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_sbv/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_sbv'
  s.version     = HitobitoSbv::VERSION
  s.authors     = ['Roland Studer']
  s.email       = ['roland@hitobito.com']
  # s.homepage    = 'TODO'
  s.summary     = 'Schweizer Blasmusikverband'
  s.description = 'Structure and additonal features for hitobito of Schweizer Blasmusikverband'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']
  # rubocop:enable SingleSpaceBeforeFirstArg
end
