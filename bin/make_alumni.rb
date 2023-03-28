#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'
require 'optimist'

opts = Optimist.options do
  opt :users, "The users to make alumni.",     :type => :strings, :required => true
  opt :org,   "The org in which user belongs", :default => "ManageIQ"

  MultiRepo.common_options(self, :only => :dry_run)
end

class MultiRepo::MakeAlumni
  attr_reader :org, :dry_run

  def initialize(org:, dry_run:, **_)
    @org     = org
    @dry_run = dry_run
    @github  = MultiRepo::Service::Github.new(dry_run: dry_run)
  end

  def run(user)
    progress = MultiRepo.progress_bar(teams.size + repos.size)

    github.add_team_membership(org, "alumni", user)
    progress.increment

    non_alumni_teams = github.team_names(org) - ["alumni"]
    non_alumni_teams.each do |team|
      github.remove_team_membership(org, team, user)
      progress.increment
    end

    repos.each do |repo|
      github.remove_collaborator(repo, user)
      progress.increment
    end

    progress.finish
  end
end

make_alumni = MultiRepo::MakeAlumni.new(opts)
opts[:users].each do |user|
  puts MultiRepo.header(user)
  make_alumni.run(user)
end
