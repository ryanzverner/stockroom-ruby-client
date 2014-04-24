Gem::Specification.new do |spec|
  spec.name          = "stockroom"
  spec.version       = "1.0.0"
  spec.authors       = ["Ryan"]
  spec.email         = ["ryanzverner@gmail.com"]
  spec.homepage      = ""
  spec.summary       = ""
  spec.description   = ""

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'httparty', '~> 0.13.1'
  spec.add_runtime_dependency 'multi_json', '~> 1.7.5'
  spec.add_runtime_dependency 'activesupport', '>= 4.0.0', '< 5.0'

  spec.add_development_dependency 'rspec', '2.14.1'
  spec.add_development_dependency 'webmock', '1.17.4'
  spec.add_development_dependency 'surrogate', '0.8.1'
end
