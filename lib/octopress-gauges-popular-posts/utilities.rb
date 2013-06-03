# Public: Module for handling the installation and removal of the Octopress Gauges Popular Post
#         plugin
module PopularPost
  module Utilities
    TEMPLATES_DIR = File.expand_path(File.dirname(__FILE__) + '/../../templates')

    # Public: Installs the templates to the designated locations
    #
    # Examples
    #
    #   PopularPost.install
    #   # => nil
    #
    # Returns nothing
    def self.install
      FileUtils.copy_file plugin_path, plugin_destination
      FileUtils.copy_file aside_path, aside_destination
      Dir.mkdir cache_path unless File.directory?(cache_path)
      FileUtils.copy_file config_path, config_destination
    end

    # Public: Removes plugin files
    #
    # Examples
    #
    #   PopularPost.remove
    #   # => nil
    #
    # Returns nothing
    def self.remove
      FileUtils.rm plugin_destination
      FileUtils.rm aside_destination
    end

    protected

    # Private: Returns the file path to the plugin template
    #
    # Examples
    #
    #   plugin_path
    #   # => /path/to/plugin.rb
    #
    # Returns a String
    def self.plugin_path
      File.join(TEMPLATES_DIR, 'popular_post.rb')
    end

    # Private: Returns the file path to the plugin destination
    #
    # Examples
    #
    #   plugin_destination
    #   # => /path/to/destination/plugin.rb
    #
    # Returns a String
    def self.plugin_destination
      File.join(Dir.pwd, 'plugins', 'popular_post.rb')
    end

    # Private: Returns the file path to the aside template
    #
    # Examples
    #
    #   aside_path
    #   # => /path/to/aside.html
    #
    # Returns a String
    def self.aside_path
      File.join(TEMPLATES_DIR, 'popular_posts.html')
    end

    # Private: Returns the file path to the aside destination
    #
    # Examples
    #
    #   aside_destination
    #   # => /path/to/destination/aside.html
    #
    # Returns a String
    def self.aside_destination
      File.join(Dir.pwd, 'source', '_includes', 'custom', 'asides', 'popular_posts.html')
    end

    # Private: Returns the file path to the cache direcetory
    #
    # Examples
    #
    #   aside_path
    #   # => /path/to/.page_views
    #
    # Returns a String
    def self.cache_path
      File.join(Dir.pwd, '.page_views')
    end

    # Private: Returns the file path to the config template
    #
    # Examples
    #
    #   aside_path
    #   # => /path/to/config
    #
    # Returns a String
    def self.config_path
      File.join(TEMPLATES_DIR, 'config')
    end

    # Private: Returns the file path to the config destination
    #
    # Examples
    #
    #   aside_path
    #   # => /path/to/destination/config
    #
    # Returns a String
    def self.config_destination
      File.join(Dir.pwd, '.page_views', 'config')
    end
  end
end
