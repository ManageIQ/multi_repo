#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :old, "The old label names.", :type => :strings, :required => true
  opt :new, "The new label names.", :type => :strings, :required => true

  MultiRepo::CLI.common_options(self)
end

rename_hash = opts[:old].zip(opts[:new]).to_h
puts "Renaming: #{rename_hash.pretty_inspect}"
puts

MultiRepo.each_repo(**opts) do |repo|
  MultiRepo::Helpers::RenameLabels.new(repo.name, rename_hash, **opts).run
end
