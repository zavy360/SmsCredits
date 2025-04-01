# encoding: utf-8

require_relative "lib/sms_credits/version"


Gem::Specification.new do |spec|
  spec.name          = "sms_credits"
  spec.version       = SmsCredits::VERSION
  spec.authors       = ["ChatGPT o3-high-mini"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = %q{A gem to calculate SMS message segments and credit usage.}
  spec.description   = %q{SmsCreditCounter is a Ruby gem that calculates the number of SMS segments required based on the content of the message. It supports GSM‑7 and Unicode encoding.}
  spec.homepage      = "https://github.com/zavy360/sms-credit-counter"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "Gemfile", "Rakefile", "spec/**/*", "sms_credits.gemspec"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter"
end