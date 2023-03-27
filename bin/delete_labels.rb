#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  opt :labels, "The labels to delete.", :type => :strings, :required => true

  MultiRepo.common_options(self, :repo_set_default => nil)
end
opts[:repo] = MultiRepo::Labels.all.keys.sort unless opts[:repo] || opts[:repo_set]

def delete(repo, label, dry_run:, **_)
  puts "Deleting #{label.inspect}"

  if dry_run
    puts "** dry-run: github.delete_label!(#{repo.inspect}, #{label.inspect})"
  else
    MultiRepo::Service::Github.client.delete_label!(repo, label)
  end
end

MultiRepo.each_repo(opts) do |repo|
  opts[:labels].each do |label|
    delete(repo.github_repo, label, opts)
  end
end
