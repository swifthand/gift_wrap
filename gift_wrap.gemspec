# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gift_wrap/version'

Gem::Specification.new do |spec|
  spec.name         = "gift_wrap"
  spec.version      = GiftWrap::VERSION
  spec.authors      = ["Paul Kwiatkowski"]
  spec.email        = ["paul@groupraise.com"]
  spec.summary      = "A Dead-Simple Presenter Library."
  spec.description  = "A dead-simple Presenter library. You include a module, call some class-level 'macro-style' methods, and suddenly you're presenting for a wrapped object. No magic. If your knowledge of pattern names comes via Rails (such as a very popular 'decorator' library), think of this like that one, except the term 'decorator' is not the best fit. Mistakes of terminology should not survive on legacy alone."
  spec.homepage     = "https://github.com/swifthand/adalog"
  spec.license      = "Revised BSD, see LICENSE.md"

  spec.files = Dir['lib/**/*.rb'] + Dir['bin/*']
  spec.files += Dir['[A-Z]*'] + Dir['test/**/*']
  spec.files.reject! { |fn| fn.include? "CVS" }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", "~> 4.0"

  spec.add_development_dependency "bundler",  "~> 1.7"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "turn-again-reporter", "~> 1.1", ">= 1.1.0"
end
