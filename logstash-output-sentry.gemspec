Gem::Specification.new do |s|
  s.name = 'logstash-output-sentry'
  s.version = "0.1.0"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "This plugin gives you the possibility to send your output to a Sentry host"
  s.description = "This plugin can be used if you want to use Sentry with Logstash. WARNING : Plugin only tested for some tests but never built. "
  s.authors = ["antho31"]
  s.email = "anthonygourraud@gmail.com"
  s.homepage = "http://github.com/antho31"
  s.require_paths = ["lib"]

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 1.4.0", "< 2.0.0"
  s.add_development_dependency "logstash-devutils"
end
