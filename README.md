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
2. Add `overrides_tracker/*` to your .gitignore file because you want to keep hold of your report file when switching branches.

3. Track your overrides by running:
    ```ruby
    bundle exec overrides_tracker track
    ```
    
    This will print out all overrides on the terminal as well as generate a nice and clean HTML summary.
    That summary can be found under overrides_tracker/summary.html and will look somewhat like this:
    
<p float="left">
<img width="800" alt="" src="https://user-images.githubusercontent.com/9799974/219690881-40c44093-70d1-4326-aa7b-8196b2f1742b.png">
</p>

4. This will create a folder called overrides_tracker and a file containing all methods you override as well as your overrides in that branch.

5. Switch branch and follow steps 1-3 again. If you want to compare multiple branches you need to redo these steps for every branch.

6. Now you have at least 2 files in the overrides_tracker folder

7. It's time to compare these overrides accross branches.
    ```ruby
    bundle exec overrides_tracker compare
    ````

8. The result will be printed on the terminal as well as written as nice and clean HTML.
   That comparison can be found under overrides_tracker/compare.html and will look somewhat like this:

<p float="left">
<img width="800" alt="" src="https://user-images.githubusercontent.com/9799974/219691633-b270db0f-8587-4b2b-91b7-8aecc36501dc.png">
</p>

## Integrate Overrides Tracker into your CI/CD pipeline with Overrides.io

Overrides.io is a service that monitors code you override for changes. It notifies you whenever those changes occur.
Additionally it gives you a beautiful overview of all the methods you have overridden as well as your overrides side by side.
<p float="left">
<img width="500" alt="" src="https://user-images.githubusercontent.com/9799974/211658325-60c21057-1a07-4b55-a4d5-3d82470fb3ee.png">
<img width="500" alt="" src="https://user-images.githubusercontent.com/9799974/211658362-f50435dd-56c5-498b-9038-f702addb0717.png">
</p>
Overrides Tracker can easily be integrated into your CI/CD pipeline and configured to send the result files to overrides.io.

You basically just have to set OVERRIDES_API_TOKEN environment variable and call 'bundle exec overrides_tracker track'.
To push it to overrides.io locally you could also just call 'bundle exec overrides_tracker track YOUR_OVERRIDES_API_TOKEN'.

You can find a detailed description how to integrate it with CircleCI, GitHub Action and Jenkins here:

https://www.overrides.io/continuous_integration

## GEM support

Overrides Tracker can also be used on GEMs. It will autoload all classes in the lib and app folders.

Sometimes that is not enough:

If you need further requirements, you can just add a .overrides_tracker folder and add a requirements.rb file to it.
In that one you can just require the classes your gem depends on. 

You can also use the ['require_all'](https://github.com/jarmo/require_all) way to include complete folders, filter files etc..

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
