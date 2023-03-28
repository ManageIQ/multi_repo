#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :branch,   "The branch to fetch.",                   :type => :string,  :required => true
  opt :checkout, "Checkout target branch after fetching.", :type => :boolean, :default => false

  MultiRepo::CLI.common_options(self, :except => :dry_run, :repo_set_default => nil)
end
opts[:repo_set] = opts[:branch] unless opts[:repo] || opts[:repo_set]

MultiRepo.each_repo(opts) do |repo|
  repo.fetch
  repo.checkout(opts[:branch]) if opts[:checkout] && opts[:branch] && !repo.config.has_real_releases
end
