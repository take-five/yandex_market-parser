# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yandex_market/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexei Mikhailov"]
  gem.email         = %w(amikhailov83@gmail.com)
  gem.description   = %q{Simple DSL for configuring parser for Yandex.Market files}
  gem.summary       = %q{Simple DSL for configuring parser for Yandex.Market files}
  gem.homepage      = "git://git.dev.apress.ru/yandex_market.git"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yandex_market"
  gem.require_paths = %w(lib)
  gem.version       = YandexMarket::VERSION

  gem.add_dependency "sax_stream", "~> 1.0.3"
  gem.add_dependency "activemodel", ">= 3.0.0"

  gem.add_development_dependency "bundler", ">= 1.0.0"
  gem.add_development_dependency "rspec", ">= 2.11.0"
  gem.add_development_dependency "simplecov", ">= 0.6.4"
  gem.add_development_dependency "appraisal", ">= 0.4.0"
end
