#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  opt :branch, "The branch to destroy.", :type => :string, :required => true

  MultiRepo.common_options(self, :except => :dry_run)
end

MultiRepo.each_repo(opts) do |repo|
  repo.chdir do
    system("git checkout master")
    system("git branch -D #{opts[:branch]}")
  end
end
