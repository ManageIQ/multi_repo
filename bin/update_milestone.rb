#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :title,  "The milestone title.",            :type => :string, :required => true
  opt :due_on, "The due date.",                   :type => :string
  opt :close,  "Whether to close the milestone.", :default => false

  MultiRepo::CLI.common_options(self)
end
Optimist.die(:due_on, "is required") if !opts[:close] && !opts[:due_on]
Optimist.die(:due_on, "must be a date format") if opts[:due_on] && !MultiRepo::Service::GitHub.valid_milestone_date?(opts[:due_on])

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Helpers::UpdateMilestone.new(repo.name, **opts).run
end
