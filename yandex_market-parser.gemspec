# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yandex_market/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexei Mikhailov"]
  gem.email         = %w(amikhailov83@gmail.com)
  gem.description   = %q{DSL for building parsers for Yandex.Market files}
  gem.summary       = %q{DSL for building parsers for Yandex.Market files}
  gem.homepage      = "https://github.com/take-five/yandex_market-parser"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yandex_market-parser"
  gem.require_paths = %w(lib)
  gem.version       = YandexMarket::VERSION

  gem.add_dependency "sax_stream", "~> 1.0.3"

  gem.add_development_dependency "bundler", ">= 1.0.0"
  gem.add_development_dependency "rspec", ">= 2.11.0"
  gem.add_development_dependency "simplecov", ">= 0.6.4"
  gem.add_development_dependency "rake", ">= 0.9.2.2"
end
