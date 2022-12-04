source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in overrides_tracker.gemspec
gemspec

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.9')
  gem 'vcr', '~> 2.9'
  gem 'webmock', '~> 1.20'
else
  gem 'vcr', '>= 2.9'
  gem 'webmock', '>= 1.20'
end