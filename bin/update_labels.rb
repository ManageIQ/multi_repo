#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  MultiRepo.common_options(self, :repo_set_default => nil)
end
opts[:repo] = MultiRepo::Labels.all.keys.sort unless opts[:repo] || opts[:repo_set]

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::UpdateLabels.new(repo.github_repo, opts).run
end
