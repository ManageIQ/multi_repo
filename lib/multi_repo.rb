require 'pathname'
require 'pp'

require 'multi_repo/labels'
require 'multi_repo/repo'
require 'multi_repo/repo_set'

require 'multi_repo/code_climate'
require 'multi_repo/hakiri'
require 'multi_repo/license'
require 'multi_repo/readme_badges'
require 'multi_repo/travis'

require 'multi_repo/string_formatting'

require 'multi_repo/backport_prs'
require 'multi_repo/destroy_tag'
require 'multi_repo/git_mirror'
require 'multi_repo/github'
require 'multi_repo/internationalization'
require 'multi_repo/pull_request_blaster_outer'
require 'multi_repo/release_branch'
require 'multi_repo/release_tag'
require 'multi_repo/rename_labels'
require 'multi_repo/rubygems_stub'
require 'multi_repo/update_branch_protection'
require 'multi_repo/update_labels'
require 'multi_repo/update_milestone'
require 'multi_repo/update_repo_settings'

module ManageIQ
  module Release
    CONFIG_DIR = Pathname.new("../../config").expand_path(__dir__)
    REPOS_DIR = Pathname.new("../../repos").expand_path(__dir__)

    #
    # CLI helpers
    #

    def self.each_repo(**kwargs)
      raise "no block given" unless block_given?

      repos_for(**kwargs).each do |repo|
        puts header(repo.github_repo)
        yield repo
        puts
      end
    end

    def self.repos_for(repo: nil, repo_set: nil, **_)
      Optimist.die("options --repo or --repo_set must be specified") unless repo || repo_set

      if repo
        Array(repo).map { |n| repo_for(n) }
      else
        MultiRepo::RepoSet[repo_set]
      end
    end

    def self.repo_for(repo)
      Optimist.die(:repo, "must be specified") if repo.nil?

      org, repo_name = repo.split("/").unshift(nil).last(2)
      MultiRepo::Repo.new(repo_name, :org => org)
    end

    def self.common_options(optimist, only: %i[repo repo_set dry_run], except: nil, repo_set_default: "master")
      optimist.banner("")
      optimist.banner("Common Options:")

      subset = Array(only).map(&:to_sym) - Array(except).map(&:to_sym)

      if subset.include?(:repo_set)
        optimist.opt :repo_set, "The repo set to work with", :type => :string, :default => repo_set_default, :short => "s"
      end
      if subset.include?(:repo)
        msg = "Individual repo(s) to work with"
        if subset.include?(:repo_set)
          sub_opts = {}
          msg << "; Overrides --repo-set"
        else
          sub_opts = {:required => true}
        end
        optimist.opt :repo, msg, sub_opts.merge(:type => :strings)
      end
      if subset.include?(:dry_run)
        optimist.opt :dry_run, "Execute without making changes", :default => false
      end
    end

    #
    # Logging helpers
    #

    HEADER_SIZE = 80

    def self.header(title, char = "=")
      title = " #{title} "
      start = (HEADER_SIZE / 2) - (title.length / 2)
      separator(char).tap { |h| h[start, title.length] = title }
    end

    def self.separator(char = "*")
      char * HEADER_SIZE
    end

    def self.progress_bar(total = 100)
      require "progressbar"
      ProgressBar.create(
        :format => "%j%% |%B| %E",
        :length => HEADER_SIZE,
        :total  => total
      )
    end

    #
    # Configuration
    #

    def self.config_files_for(prefix)
      Dir.glob(CONFIG_DIR.join("#{prefix}*.yml")).sort
    end

    def self.load_config_file(prefix)
      config_files_for(prefix).each_with_object({}) do |f, h|
        h.merge!(YAML.unsafe_load_file(f))
      end
    end

    def self.github_api_token
      @github_api_token ||= ENV["GITHUB_API_TOKEN"]
    end

    def self.github_api_token=(token)
      @github_api_token = token
    end

    def self.travis_api_token
      @travis_api_token ||= ENV["TRAVIS_API_TOKEN"]
    end

    def self.travis_api_token=(token)
      @travis_api_token = token
    end

    #
    # Services
    #

    def self.github
      @github ||= begin
        raise "Missing GitHub API Token" if github_api_token.nil?

        params = {
          :access_token  => github_api_token,
          :auto_paginate => true
        }
        params[:api_endpoint] = ENV["GITHUB_API_ENDPOINT"] if ENV["GITHUB_API_ENDPOINT"]

        require 'octokit'
        Octokit::Client.new(params)
      end
    end

    def self.github_repo_names_for(org)
      github
        .list_repositories(org, :type => "sources")
        .reject { |r| r.fork? || r.archived? }
        .map { |r| "#{org}/#{r.name}" }
    end

    def self.travis
      @travis ||= begin
        raise "Missing Travis API Token" if travis_api_token.nil?

        require 'travis/client'
        ::Travis::Client.new(
          :uri           => ::Travis::Client::COM_URI,
          :access_token  => travis_api_token
        )
      end
    end
  end
end
