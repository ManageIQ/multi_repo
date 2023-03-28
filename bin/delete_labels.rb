#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :labels, "The labels to delete.", :type => :strings, :required => true

  MultiRepo::CLI.common_options(self, :repo_set_default => nil)
end
opts[:repo] = MultiRepo::Helpers::Labels.all.keys.sort unless opts[:repo] || opts[:repo_set]

github = MultiRepo::Service::Github.new(dry_run: opts[:dry_run])

MultiRepo.each_repo(opts) do |repo|
  opts[:labels].each do |label|
    puts "Deleting #{label.inspect}"
    github.delete_label!(repo.name, label)
  end
end
