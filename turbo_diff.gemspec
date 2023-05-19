require_relative "lib/turbo_diff/version"

Gem::Specification.new do |spec|
  spec.name = "turbo_diff"
  spec.version = TurboDiff::VERSION
  spec.authors = [ "Jorge Manrubia" ]
  spec.email = [ "jorge@hey.com" ]
  spec.summary = "Diff rendering engine for Turbo"
  spec.license = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4"
  spec.add_dependency "zeitwerk"
  spec.add_dependency "nokolexbor"

  spec.add_dependency 'importmap-rails'
  spec.add_dependency 'turbo-rails'
  spec.add_dependency 'stimulus-rails'

  spec.add_development_dependency "capybara"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
end
