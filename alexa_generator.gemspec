$:.push File.expand_path('../lib', __FILE__)

require "alexa_generator/version"

Gem::Specification.new do |gem|
  gem.name    = 'alexa_generator'
  gem.version = AlexaGenerator::VERSION

  gem.summary = "Generates voice interfaces for Alexa apps based on templates."

  gem.authors  = ['Christopher Mullins']
  gem.email    = 'chris@sidoh.org'
  gem.homepage = 'http://github.com/sidoh/alexa_generator'

  gem.add_development_dependency('rspec', [">= 2.0.0"])

  ignores  = File.readlines(".gitignore").grep(/\S+/).map(&:chomp)
  dotfiles = %w[.gitignore]

  all_files_without_ignores = Dir["**/*"].reject { |f|
    File.directory?(f) || ignores.any? { |i| File.fnmatch(i, f) }
  }

  gem.files = (all_files_without_ignores + dotfiles).sort

  gem.require_path = "lib" 
end
