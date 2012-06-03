# Guard::Drush

Drush guard allows to automatically call a drush command when one or more files change.

## Install

Please be sure to have [Guard](https://github.com/guard/guard) installed before continuing.

Install the gem:

``` bash
$ gem install guard-drush
```

Add a guard definition to your Guardfile like:

``` ruby
guard :drush, :command => "prepro" do
  watch(%r{.+\.(scss|coffee)$})
end
```

That drush command gets called with a list of paths to changed files as its arguments when a file changes.

## Usage

Please read [Guard usage doc](http://github.com/guard/guard#readme).

## Setting the right @sitealias
The site alias to run the command against can be specified in your Guardfile (using the :alias option) but (as is most likely) you'll want to re-use that Guardfile for more than one site. As such it is also possible to specify the sitealias when running guard with the following syntax:

``` bash
DRUSH_ALIAS=@mysitealias guard
```

## Options

Drush guard has some options that you can set like this:

``` ruby
guard :drush, :command => 'status', :alias => '@sitealias' do
  # ...
end
```

Available options:

``` ruby
:command => 'status'              # required. The drush command to run.
:alias => '@mysitealias'          # optional, the site to run it against
:drush_live => false              # default true. Pass false to *not* use the drush_live drush command if present
:drush_live_auto_reload => false  # default true. Pass drush_live argument through.
:drush_live_timeout => 180        # default 1800. Pass drush_live argument through.
```
## Drush live
If [Drush live](http://drupal.org/project/drush_live) is present on the system guard-drush will use it (with the --auto-reload) option to speed up the response time of your drush command as much as possible. Install drush_live with the following command:

``` bash
drush dl drush_live
```

If your drush command does not need a bootstrapped Drupal or you are having problems with drush_live you can choose to not use it with the :drush_live => false option:

``` ruby
guard :drush, :command => 'status', :alias => '@sitealias', :drush_live => false do
  # ...
end
```
