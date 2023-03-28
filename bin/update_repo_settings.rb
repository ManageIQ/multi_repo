#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  MultiRepo::CLI.common_options(self)
end

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Helpers::UpdateRepoSettings.new(repo.name, **opts).run
end
