Gem::Specification.new do |s|
  s.authors           = ["Jens Becker"]
  s.email             = ["v2px@v2px.de"]
  s.description       = "A modular, event-driven IRC client/bot Ruby gem with plugin support"
  s.summary           = "A modular, event-driven IRC client/bot Ruby gem with plugin support"
  s.homepage          = "http://v2px.github.com/fantasy-irc"
  s.license           = 'MIT'

  s.files             = `git ls-files`.split("\n")
  s.name              = "fantasy-irc"
  s.require_paths     = ['lib']
  s.version           = "0.3.0"

  s.rubyforge_project = s.name
  s.add_runtime_dependency "array-unique", "~> 1.1.1"
end
