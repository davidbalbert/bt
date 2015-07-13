# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bt/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Albert"]
  gem.email         = ["davidbalbert@gmail.com"]
  gem.description   = %q{A Ruby BitTorrent library}
  gem.summary       = %q{A Ruby BitTorrent library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bt"
  gem.require_paths = ["lib"]
  gem.version       = BT::VERSION

  gem.add_development_dependency "pry", "~> 0.9.10"
  gem.add_development_dependency "pry-debundle", "~> 0.6"
end
