#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

success = MultiRepo::Helpers::GitMirror.new.mirror_all
exit 1 unless success
