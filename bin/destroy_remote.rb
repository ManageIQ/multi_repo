#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :remote, "The remote to destroy", :type => :string, :required => true

  MultiRepo::CLI.common_options(self)
end

MultiRepo.each_repo(opts) do |repo|
  next unless repo.remote?(opts[:remote])

  if opts[:dry_run]
    puts "** dry-run: git rm #{opts[:remote]}"
  else
    repo.git.remote("rm", opts[:remote])
  end
end
