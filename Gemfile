source "https://rubygems.org"

plugin 'bundler-inject'
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem "activesupport",        :require => false
gem "actionview",           :require => false
gem "colorize",             :require => false
gem "config",               :require => false
gem "licensee",             :require => false
gem "minigit",              :require => false
gem "more_core_extensions", :require => false
gem "octokit", ">=4.23.0",  :require => false
gem "optimist",             :require => false
gem "progressbar",          :require => false
gem "psych", ">=3",         :require => false
gem "rbnacl",               :require => false
gem "rest-client",          :require => false
gem "travis",               :require => false

group :development do
  gem "manageiq-style", :require => false
  gem "rspec",          :require => false
end
