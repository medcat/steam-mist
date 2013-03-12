$LOAD_PATH.unshift 'lib'
require "steam_mist/version"
 
Gem::Specification.new do |s|
  s.name              = "steam_mist"
  s.version           = SteamMist::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "An interface to the Steam API."
  s.homepage          = "http://github.com/redjazz96/steam_mist"
  s.email             = "redjazz96@gmail.com"
  s.authors           = [ "redjazz96" ]
 
  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.description       = <<desc
  An interface for the Steam API.
desc

  s.add_dependency "oj", '~> 1.6'
end
