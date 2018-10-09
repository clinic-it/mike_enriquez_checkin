source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '0.20'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
#gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'jquery-rails', '4.3.3'

gem 'bootstrap', '~> 4.0.0.alpha6'
gem 'font-awesome-rails', '4.7.0.4'
gem 'chartkick', '2.2.4'
gem 'draper', '3.0.1'

gem 'kaminari', '1.1.1'
gem 'jquery-tablesorter', '1.26.0'

gem 'haml', '5.0.4'
gem 'slack-ruby-client', '0.13.1'
gem 'figaro', '1.1.1'
gem 'tracker_api', '1.9.0'
gem 'reform-rails', '0.1.7'
gem 'httparty', '0.16.2'

gem 'jquery-datatables', '1.10.16'
gem 'ruby-freshbooks', '0.4.1'
gem 'jquery-ui-rails', '6.0.1'
gem 'annotate', '2.7.4'
gem 'momentjs-rails', '2.20.1'
gem 'fullcalendar-rails', '3.9.0.0'

# Used to generate image
gem 'imgkit', '1.6.1'
gem 'wkhtmltoimage-binary', '0.12.4'

# Used for pdf report generation
gem 'wicked_pdf', '1.1.0'
gem 'wkhtmltopdf-binary', '0.12.3.1'
gem 'rmagick', '2.16.0', :require => 'RMagick'
gem 'grim', '1.3.2'

# Used to upload image to s3
gem 'paperclip', '5.1.0'
gem 'aws-sdk', '2.9.29'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

group :production do
  gem 'wkhtmltopdf-heroku', '2.12.4.0'
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end
