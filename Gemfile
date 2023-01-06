source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'coveralls_reborn', '~> 0.25.0', require: false
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', '~> 0.8.0'
end

# Specify your gem's dependencies in overrides_tracker.gemspec
gemspec

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.9')
  gem 'vcr', '~> 2.9'
  gem 'webmock', '~> 1.20'
else
  gem 'vcr', '>= 2.9'
  gem 'webmock', '>= 1.20'
end
