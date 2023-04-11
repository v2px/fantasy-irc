lib = File.expand_path("lib", __dir__).freeze
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require File.expand_path('../lib/fantasy-irc/version', __FILE__)

Gem::Specification.new do |s|
  s.authors = ["Jens Becker", "Afri Schoedon"]
  s.email = ["v2px@v2px.de", "gems@q9f.cc"]
  s.description = "A modular, event-driven IRC client and bot with plugin support."
  s.summary = "An IRC bot with plugin support."
  s.homepage = "http://v2px.github.com/fantasy-irc"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.name = "fantasy-irc"
  s.require_paths = ["lib"]
  s.version = Fantasy::VERSION

  s.add_runtime_dependency "array-unique", "~> 1.1"
  s.add_runtime_dependency "ddate", "~> 1.0"
end
