#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require "multi_repo/cli"

opts = Optimist.options do
  opt :org,    "The org to list the users for",    :type => :string, :required => true
  opt :team,   "Show members of a specific team",  :type => :string
  opt :alumni, "Whether or not to include alumni", :default => false
end

github = MultiRepo::Service::Github.new
members  = opts[:team] ? github.team_member_names(opts[:org], opts[:team]) : github.org_member_names(opts[:org])
members -= github.team_member_names(opts[:org], "alumni") unless opts[:alumni]

puts members
