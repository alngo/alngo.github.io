source "https://rubygems.org"

gem "jekyll", "~> 4.2.2"

# Theme
gem "minima", "~> 2.5.1"

# Pugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.15.1"
end

# Windows and JRuby does not include zoneinfo files, 
# so bundle the tzinfo-data gem and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# If you are using Ruby 3.0 and Jekyll 4.2.x or older, 
# you will need to add the webrick gem to your project's Gemfile 
gem "webrick", "~> 1.3", ">= 1.3.1"

