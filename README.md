# Overrides Tracker
Overrides Tracker keeps track of all overriding methods in your project and allows for comparison across branches.

[![Gem Version](https://badge.fury.io/rb/overrides_tracker.svg)](https://badge.fury.io/rb/overrides_tracker)
[![Coverage Status](https://coveralls.io/repos/github/SyborgStudios/overrides_tracker/badge.svg?branch=master)](https://coveralls.io/github/SyborgStudios/overrides_tracker?branch=master)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/SyborgStudios/overrides_tracker/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/SyborgStudios/overrides_tracker/tree/master)

## Contact

*Code and Bug Reports*

* [Issue Tracker](https://github.com/SyborgStudios/overrides_tracker/issues)
* See [CONTRIBUTING]


Getting started
---------------
1. Add OverridesTracker to your Gemfile and bundle install:

    ```ruby
    gem 'overrides_tracker', group: [:test, :development]
    ```
2. Add `overrides_tracker/*.otf` to your .gitignore file because you want to keep hold of your report file when switching branches.

3. Track you overrides by running:
    ```ruby
    bundle exec overrides_tracker track
    ```
    
    The output will look like this.
    
    ```
    Reading all methods...
    Checking...AClass
    Checking...BClass
    Method is a new instance method: AClass#a_new_method
    Method is instance override: AClass#a_instance_method_override
    .
    .
    .
    Checking...YClass
    Method is a new singleton method: YClass#a_new_method
    Method is singleton override: YClass#a_singelton_method_override
    Checking...ZClass

    ===========
    Report saved to /PATH_TO_PROJECT/overrides_tracker/BRANCH_NAME#LAST_COMMIT_ID.otf
    ```

4. This will create a folder called overrides_tracker and a file containing all methods you override as well as your overrides in that branch.

5. Switch branch and follow steps 1-3 again. If you want to compare multiple branches you need to redo these steps for every branch.

6. Now you have at least 2 files in the overrides_tracker folder

7. It's time to compare these overrides accross branches.
    ```ruby
    bundle exec overrides_tracker compare
    ````

8. The result gives you an overview on what has changed and what not.

    ```
    ===========================================================================================

    1) BClass#a_instance_method_override: No Changes

    ===========================================================================================

    2)....
    .
    .
    .

    ===========================================================================================

    26) YClass#a_singelton_method_override: Changes between files

    in: master#528a0206d8f7cfe08737193659f85e28ccb260eb.otf
    YClass#a_singelton_method_override:

    Source:
    def self.a_singelton_method_override
      does_stuff_one_way
    end

    ../.rbenv/versions/2.3.8/lib/ruby/gems/2.3.0/bundler/gems/some_gem/lib/some_gem/y_class.rb:2

    Override:
    def self.a_singelton_method_override
      does_stuff_one_way_but_slitly_different
    end

    /PATH_TO_PROJECT/app/models/decorators/y_class_decorator.rb:13


    in: upgrade_to_latest#beadcdd8e07a2c9dc2aefddeef04fc42e6fff0d5.otf
    YClass#a_singelton_method_override:

    Source:
    def self.a_singelton_method_override
      does_stuff_in_a_different_way
    end

    ../.rbenv/versions/2.3.8/lib/ruby/gems/2.3.0/bundler/gems/some_gem/lib/some_gem/y_class.rb:2

    Override:
    def self.a_singelton_method_override
      does_stuff_one_way_but_slitly_different
    end

    /PATH_TO_PROJECT/app/models/decorators/y_class_decorator.rb:13

    ===========================================================================================

    Summary:
    Found 29 distinct overridden methods
    10 overridden methods have not changed
    19 overridden methods have changed
    1 where method is not an override
    4 where method is not in codebase
    15 source method bodies have changed
    ```
    
## GEM support

Overrides Tracker can also be used on GEMs. It will autoload all classes in the lib and app folders.

Sometimes that is not enough:

If you need further requirements, you can just add a .overrides_tracker folder and add a requirements.rb file to it.
In that one you can just require the classes your gem depends on. 

You can also use the ['require_all'](https://github.com/jarmo/require_all) way to include complete folders, filter files etc..

## Overrides.io integration
<img width="1000" alt="Bildschirm­foto 2023-01-10 um 21 39 42" src="https://user-images.githubusercontent.com/9799974/211657428-c2a7e272-ae86-4c1c-8e77-0a07acc1a4a0.png">

Overrides.io is a service that monitors code you override for changes. It notifies you whenever those changes occur.
Additionally it gives you a beautiful overview of all the methods you have overridden as well as your overrides side by side.
<p float="left">
<img width="500" alt="Bildschirm­foto 2023-01-10 um 21 39 15" src="https://user-images.githubusercontent.com/9799974/211658325-60c21057-1a07-4b55-a4d5-3d82470fb3ee.png">
<img width="500" alt="Bildschirm­foto 2023-01-10 um 21 39 28" src="https://user-images.githubusercontent.com/9799974/211658362-f50435dd-56c5-498b-9038-f702addb0717.png">
</p>
Overrides Tracker can easily be integrated into you CI/CD pipeline and configured to send the result files to overrides.io.

You basically just have to set OVERRIDES_API_TOKEN environment variable and call 'bundle exec overrides_tracker track'.
To push it to overrides.io locally you could also just call 'bundle exec overrides_tracker track YOUR_OVERRIDES_API_TOKEN'.

You can find a detailed description how to integrate it with CircleCI, GitHub Action and Jenkins here:

https://www.overrides.io/continuous_integration

## Ruby version compatibility

Overrides Tracker is built in [Continuous Integration] on Ruby 2.3+.

## Code of Conduct

Everyone participating in this project's development, issue trackers and other channels is expected to follow our
[Code of Conduct](./CODE_OF_CONDUCT.md)

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## Copyright

Copyright (c) 2023 Simon Meyborg. See MIT-LICENSE for details.
