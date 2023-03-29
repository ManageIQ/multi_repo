#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :users, "The users to make alumni.",     :type => :strings, :required => true
  opt :org,   "The org in which user belongs", :default => "ManageIQ"

  MultiRepo::CLI.common_options(self, :only => :dry_run)
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
