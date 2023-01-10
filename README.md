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

    1) Override: OrdinaryGem::AnotherTypicalClass#a_singleton_method_that_stays_the_same

    ...........................................................................................

    main#cc5a31dc4833734a177f01bd161047f8c7909e16.otf
    -------------------------------------------------------------------------------------------

    Original:

    def self.a_singleton_method_that_stays_the_same
      "This is the implementation of a simple singleton method."
      "This method will stay the same in the next version."
    end


    in BUNDLE_PATH/bundler/gems/ordinary-gem-e67e062189bb/lib/ordinary_gem/another_typical_class.rb:19


    -------------------------------------------------------------------------------------------

    Override:

    def self.a_singleton_method_that_stays_the_same
      "This is our override of a simple singleton method."
      "This method should stay the same in the next version."
    end


    in: APP_PATH/app/models/ordinary_gem/another_typical_class_monkey_patch.rb:2



    ...........................................................................................

    attached-to-next-version#a7231014c006a4a5848eb4d92bb465eb5c89ee01.otf
    -------------------------------------------------------------------------------------------

    Original:

    def self.a_singleton_method_that_stays_the_same
      "This is the implementation of a simple singleton method."
      "This method will stay the same in the next version."
    end


    in BUNDLE_PATH/bundler/gems/ordinary-gem-f92e5a1a70a6/lib/ordinary_gem/another_typical_class.rb:13


    -------------------------------------------------------------------------------------------

    Override:

    def self.a_singleton_method_that_stays_the_same
      "This is our override of a simple singleton method."
      "This method should stay the same in the next version."
    end


    in: APP_PATH/app/models/ordinary_gem/another_typical_class_monkey_patch.rb:2



    ...........................................................................................

    main#1d279724b26c9491e6e5a01e9711b61a73e9f7e0.otf
    Method not available





    ...........................................................................................
    .
    .
    .
    .
    ===========================================================================================

    Summary:

    Investigated methods: 70
    Diffences on overrides: 42
    Diffences on added methods: 28

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
