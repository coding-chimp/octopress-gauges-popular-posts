require 'yaml'
require 'json'
require 'open-uri'

# Public: Popular posts plugin for Octopress. This plugin
#         opens up the Jekyll Post and Site classes to allow
#         Jekyll to render the popular posts aside section
module PopularPost
  module Post

    def self.included(base)
      if base.class.instance_methods.include?('page_views') ||
          base.class.protected_instance_methods.include?(%w(cache_page_views read_page_views_cache))
        raise 'Octopress Gauges Popular Posts: Name clashes'
      else
        base.class_eval do
          include PublicInstanceMethods
          protected
          include ProtectedInstanceMethods
        end
      end
    end

    module PublicInstanceMethods

      PAGE_VIEWS_CACHE = '.page_views'

      # Public: Returns the page views of the post. It also caches the page views.
      #         If a cached page rank is found, it returns the cached version.
      #
      # Examples
      #
      #   page_views
      #   # => 34
      #
      # Returns the Integer page views of the post
      def page_views
        post_name = self.url.split('/').last
        cache_dir_path = File.join(Dir.pwd, PAGE_VIEWS_CACHE)
        post_path = File.join(Dir.pwd, PAGE_VIEWS_CACHE, post_name)

        if File.exists?(post_path)
          read_page_views_cache(post_path)[:views]
        else
          post_views = 0
          page_views_content = { path: self.url, views: post_views }
          cache_page_views(page_views_content, post_path)
          post_views
        end
      end
    end

    module ProtectedInstanceMethods

      # Private: Caches the page views of the post.
      #
      # page_views_content - The Hash which is contains view and
      #                      the path of the post.
      # cache_path         - The String which is the file path
      #                      to the cache
      #
      # Examples
      #
      #   cache_page_views({path: '/blog/bar', views: 2}, '/path/to/cache')
      #   # => nil
      #
      # Returns nothing.
      def cache_page_views(page_views_content, cache_path)
        File.open(cache_path, 'w') do |file|
          file.puts YAML.dump(page_views_content)
        end
      end

      # Private: Reads the cached page views
      #
      # cache_path - The String which is the file path to the cache
      #
      # Examples
      #
      #   read_page_views('/path/to/cache')
      #   # => {path: 'http://foo', views: 2}
      #
      # Returns a Hash
      def read_page_views_cache(cache_path)
        YAML.load_file(cache_path)
      end
    end
  end # Post

  module Site

    CACHE_DIR_PATH = File.join(Dir.pwd, '.page_views')

    def self.included(base)
      base.class_eval do
        attr_accessor :popular_posts
        alias_method :old_read, :read
        alias_method :old_site_payload, :site_payload

        # Public: Making use of the read method to define popular
        #         posts. Popular posts are sorted by page views
        #
        # Examples
        #
        #   read
        #   # => nil
        #
        # Returns nothing
        def read
          old_read
          update_views
          self.popular_posts = self.posts.sort do |post_x, post_y|
            if post_y.page_views > post_x.page_views then 1
            elsif post_y.page_views == post_x.page_views then 0
            else -1
            end
          end
        end

        # Public: We need to add popular_posts to site_payload, so that
        #         it gets passed to Liquid to be rendered.
        #
        # Examples
        #
        #   site_payload
        #   # => nil
        #
        # Returns nothing
        def site_payload
          old_site_hash = old_site_payload
          old_site_hash["site"].merge!({"popular_posts" => self.popular_posts})
          old_site_hash
        end

        protected

        # Private: Checks wether there is a last_run or signup_date and
        #          fetches views since then.
        #
        # Examples
        #
        #   update_views
        #   # => nil
        #
        # Returns nothing
        def update_views
          gauges_config = YAML.load_file("#{CACHE_DIR_PATH}/config")
          views = load_views
          last_run = gauges_config[:last_run] ||  gauges_config[:signup_date]
          yesterday = Date.today - 1

          if last_run.nil?
            views = fetch_views(views, yesterday, gauges_config[:token])
          elsif last_run && last_run != Date.today
            for date in last_run..yesterday do
              views = fetch_views(views, date, gauges_config[:token])
            end
          end

          cache_views(views)
          update_last_run(gauges_config)
        end

        # Private: Sets the last run date to today and caches it.
        #
        # gauges_config - The path to the gauges config file
        #
        # Examples
        #
        #   update_last_run('/path/to/page/gauges/config')
        #   # => nil
        #
        # Returns nothing
        def update_last_run(gauges_config)
          gauges_config[:last_run] = Date.today
          File.open("#{CACHE_DIR_PATH}/config", 'w') do |file|
            file.puts YAML.dump(gauges_config)
          end
        end

        # Private: Caches the views.
        #
        # views - A hash of hashes that contain the page views
        #         and path of the post.
        #
        # Examples
        #
        #   cache_views({{path: '/blog/bar', views: 2}, ...})
        #   # => nil
        #
        # Returns nothing
        def cache_views(views)
          views.each do |k, v|
            content = { path: k, views: v }
            file_path = "#{CACHE_DIR_PATH}#{k.to_s}"

            File.open(file_path, 'w') do |file|
              file.puts YAML.dump(content)
            end
          end
        end

        # Private: Loads the view counts from the cache.
        #
        # Examples
        #
        #   load_views
        #   # => {{path: '/blog/bar', views: 2}, ...}
        #
        # Returns a hash of of hashes that contain the path and
        # views of a post
        def load_views
          posts = {}
          Dir.foreach(CACHE_DIR_PATH) do |file|
            next if file == '.' || file == '..' || file == 'config'
            content = YAML.load_file("#{CACHE_DIR_PATH}/#{file}")
            posts[content[:path]] = content[:views]
          end
          posts
        end

        # Private: Takes the the current views loaded from cash,
        #          calls the Gaug.es API for the views of a specified
        #          day, updates the loaded views and returns them.
        #
        # views - An hash of hashes containing the path and views
        #         of posts  loaded from the cache
        # date  - The date for which the API call will be made
        # token - The Gaug.es API token needed for the API call
        #
        # Examples
        #
        #   fetch_views({{path: '/blog/bar', views: 2}, ...},
        #               2013-06-03, 188fa4710f08973145c1038af83ba78b)
        #   # => {{path: '/blog/bar', views: 11}, ...}
        #
        # Returns a hash of hashed containing the path and updated page
        # updated page views 
        def fetch_views(views, date, token)
          puts "Popular posts: fetches views for #{date}"
          gauge_id = config['gauges_tracking_id']
          host = config['url'].gsub "http://", ""

          content = JSON.parse(open("https://secure.gaug.es/gauges/#{gauge_id}/content?date=#{date}",
                                    'X-Gauges-Token' => token).read)['content']

          content.each do |page|
            unless page['path'] == "/"          || page['path'].include?("/categories/") ||
                   page['path'] == "/archives/" || page['path'].include?("/page/")       ||
                   page['path'] == "/about/"    || page['host'] != host
              path = page['path'].gsub(/(\/|\/#.*)$/, "")
              current_views = views[path]
              if current_views.nil?
                updated_views = page['views'].to_i
              else
                updated_views = current_views.to_i + page['views'].to_i
              end
              views[path] = updated_views
            end
          end
          views
        end

      end
    end # included
  end # Site

end # PopularPost

module Jekyll
  class Post
    include PopularPost::Post
  end

  class Site
    include PopularPost::Site
  end
end
