lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'overrides_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = 'overrides_tracker'
  spec.version       = OverridesTracker::VERSION
  spec.authors       = ['Simon Meyborg']
  spec.email         = ['meyborg@syborgstudios.com']

  spec.summary       = 'Overrides Tracker tracks all monkey patches in your codebase and the methods they override. It allows for comparison between builds to reveal changes you might miss otherwise.'
  spec.description   = 'Overrides Tracker tracks all monkey patches in your codebase and the methods they override. It allows for comparison between builds to reveal changes you might miss otherwise. Use overrides.io to integrate overrides_tracker into your CI/CD pipeline. That way you will never miss an underlying code-change that might break a monkey patch.'
  spec.homepage      = 'https://github.com/SyborgStudios/overrides_tracker'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = 'https://github.com/SyborgStudios/overrides_tracker/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
  end

  spec.bindir        = 'bin'
  spec.executables   = ['overrides_tracker']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'method_source'
end
