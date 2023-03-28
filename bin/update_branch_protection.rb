#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :branch, "The branch to protect.", :type => :string, :required => true

  MultiRepo::CLI.common_options(self, :repo_set_default => nil)
end
opts[:repo_set] = opts[:branch] unless opts[:repo] || opts[:repo_set]

MultiRepo::CLI.repos_for(**opts).each do |repo|
  next if opts[:branch] != "master" && repo.config.has_real_releases

  puts MultiRepo.header(repo.name)
  MultiRepo::Helpers::UpdateBranchProtection.new(repo.name, **opts).run
  puts
end
