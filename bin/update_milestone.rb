#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  opt :title,  "The milestone title.",            :type => :string, :required => true
  opt :due_on, "The due date.",                   :type => :string
  opt :close,  "Whether to close the milestone.", :default => false

  MultiRepo.common_options(self)
end
Optimist.die(:due_on, "is required") if !opts[:close] && !opts[:due_on]
Optimist.die(:due_on, "must be a date format") if opts[:due_on] && !MultiRepo::UpdateMilestone.valid_date?(opts[:due_on])

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::UpdateMilestone.new(repo, opts).run
end
