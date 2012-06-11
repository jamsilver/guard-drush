#!/bin/bash

sudo gem uninstall guard-drush
rm guard-drush-*.gem
gem build guard-drush.gemspec
rvmsudo gem install ./guard-drush-*.gem
