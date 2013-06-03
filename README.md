# Octopress Gauges Popular Posts Plugin #

Popular posts plugin adds a popular asides section to your [Octopress][1] blog. Popularity of the posts is calculated by page views tracked through [Gaug.es][2].

This gem is modelled after the [octopress-popular-posts gem][2]. 

## Installation ##

Add this line to your application's Gemfile:

    gem 'octopress-gauges-popular-posts'

Install it using Bundler:

    $ bundle

And run the installation to copy the plugin to your source:

    $ bundle exec octopress-gauges-popular-posts install

## Post install configurations ##

Add the Gaug.es Tracking ID of your blog and your Gaug.es API token to your **config.yml**:

    gauges_tracking_id: <your-tracking-id>

Also add the following line:

    popular_posts_count: 5      # Posts in the sidebar Popular Posts section

This sets the number of popular posts to show. 

Next, we need to add the popular post aside section:

    default_asides: [custom/asides/about.html, custom/asides/subscribe.html, custom/asides/popular_posts.html, asides/recent_posts.html, asides/github.html, asides/twitter.html, asides/delicious.html, asides/pinboard.html, asides/googleplus.html]

Note the **custom/asides/popular_posts.html** that is added on the third entry of the array.

The installation created the `config` file in the `.page_views` directory. In there you have to add your Gaug.es API token and you can also add the date started tracking your site with Gaug.es.

    :token: <your-api-token>
    :signup_date: 2013-06-03

If a `singup_date` is given, thes gem will fetch the views since then. Depending on the distance, this may take a while.

Once done, you need to generate the blog:
    
    $ rake generate

I also suggest that you ignore the cached page views files and the config file with your Gaug.es API token by adding this line to your **.gitignore**:

    .page_views

## Usage ##

Once installed, the popular posts asides section will be generated whenever you run

    $ rake generate

No additional steps are necesary.

## Updating the plugin ##

After updating the gem:

    $ bundle update octopress-gauges-popular-posts

Run the following command:

    $ bundle exec octopress-gauges-popular-posts install

## Removal ##

To remove the plugin, run the following command:

    $ bundle exec octopress-gauges-popular-posts remove

You will also need to remove the following configurations:

1. The octopress-popular-posts gem from your **Gemfile**
2. The **gauges_tracking_id** variable from your **config.yml**
3. The **popular_posts_count** variable from your **config.yml**
4. The popular posts asides under **defaults_asides** from your **config.yml**
5. The cache directory **.page_views**

## Contributing ##

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://octopress.org
[2]: http://get.gaug.es
[2]: https://github.com/octothemes/popular-posts