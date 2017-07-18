source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap', '~> 4.0.0.alpha6'
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end

gem 'kaminari'
gem 'jquery-tablesorter'

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


# Used as a decorator
gem 'draper', '2.1.0'

# Used to create charts
gem 'chartkick', '2.2.4'

# Used for icons
gem 'font-awesome-rails', '4.5.0.1'


# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  gem 'wkhtmltopdf-heroku', '2.12.4.0'
end

gem 'rails_12factor', group: :production

gem 'haml'
gem 'slack-ruby-client'
gem 'figaro'
gem 'tracker_api'
gem 'reform-rails'

ruby '2.2.1'
