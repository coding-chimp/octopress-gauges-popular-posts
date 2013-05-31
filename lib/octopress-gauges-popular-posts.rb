require 'fileutils'
require "octopress-gauges-popular-posts/version"
require 'octopress-gauges-popular-posts/utilities'

# Handles the command line options
if ARGV.length == 1 && ARGV[0] == 'install'
  PopularPost::Utilities.install
  puts 'Octopress Gauges Popular Posts plugin: installed'
  puts 'Please view the README on https://github.com/coding-chimp/octopress-gauges-popular-posts for post installation configurations.'
elsif ARGV.length == 1 && ARGV[0] == 'remove'
  PopularPost::Utilities.remove
  puts 'Octopress Gauges Popular Posts plugin: removed'
  puts 'Please view the README on https://github.com/coding-chimp/octopress-gauges-popular-posts for post removal configurations.'
else
  puts 'Usage: octopress-gauges-popular-posts [install|remove]'
end
