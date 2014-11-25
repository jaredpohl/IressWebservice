# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'IressWebservice/version'

Gem::Specification.new do |spec|
  spec.name          = "IressWebservice"
  spec.version       = IressWebservice::VERSION
  spec.authors       = ["Jared Pohl"]
  spec.email         = ["jared.pohl@gmail.com"]
  spec.description   = %q{A ruby wrapper for the Iress Desktop Web Services}
  spec.summary       = %q{Connect ruby to the Iress Desktop Web Services}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "savon", "~>2.5.0"
  spec.add_runtime_dependency "win32-service", "~> 0.8.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rpsec"

end
