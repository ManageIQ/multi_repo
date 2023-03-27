#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  opt :owners, "Owners to add to the gem stub", :type => :strings, :default => []

  MultiRepo.common_options(self, :except => :repo_set)
end

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Service::RubygemsStub.new(repo.name, opts).run
end
