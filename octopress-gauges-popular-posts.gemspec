# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-gauges-popular-posts/version'

Gem::Specification.new do |gem|
  gem.name          = "octopress-gauges-popular-posts"
  gem.version       = PopularPosts::VERSION
  gem.authors       = ["Bastian Bartmann"]
  gem.email         = ["xarfai27@gmail.com"]
  gem.description   = "Octopress Gauges Popular Posts adds a popular posts asides section to your Octopress blog. It makes use of GitHub's Gaug.es to determine the popularity of the posts."
  gem.summary       = 'Adds a popular posts asides section to your Octopress blog.'
  gem.homepage      = "https://github.com/coding-chimp/octopress-gauges-popular-posts"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
