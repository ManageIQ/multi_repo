#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  MultiRepo.common_options(self)
end

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Helpers::UpdateRepoSettings.new(repo.github_repo, opts).run
end
