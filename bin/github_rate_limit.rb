#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

puts [MultiRepo::Service::Github.client.rate_limit.to_h].tableize
