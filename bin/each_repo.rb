#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :command, "A command to run in each repo", :type => :string, :required => true
  opt :ref, "Ref to checkout before running the command", :type => :string, :default => "master"

  MultiRepo::CLI.common_options(self, :except => :dry_run)
end

MultiRepo.each_repo(**opts) do |r|
  r.fetch
  r.checkout(opts[:ref])
  r.chdir do
    puts "+ #{opts[:command]}"
    system(opts[:command])
  end
end
