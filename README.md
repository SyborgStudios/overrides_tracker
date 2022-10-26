# Overrides Tracker
Overrides Tracker keeps track of all overriding methods in your project and allows for comparison across branches.

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
2. Add `overrides_tracker/*.otf` to your .gitignore file because you do won't to keep hold of your report file when changing branches.

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

4. This will create a folder called overrides_tracker and creates a file containing all overriding methods of your branch.

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
    
## Ruby version compatibility

OverridesTracker is built in [Continuous Integration] on Ruby 2.3+.

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

Copyright (c) 2022 Simon Meyborg. See MIT-LICENSE for details.
