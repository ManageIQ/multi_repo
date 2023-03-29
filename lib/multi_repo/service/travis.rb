require 'yaml'

module MultiRepo::Service
  class Travis
    def self.api_token
      @api_token ||= ENV["TRAVIS_API_TOKEN"]
    end

    def self.api_token=(token)
      @api_token = token
    end

    def self.client
      @client ||= begin
        raise "Missing Travis API Token" if travis_api_token.nil?

        require 'travis/client'
        ::Travis::Client.new(
          :uri           => ::Travis::Client::COM_URI,
          :access_token  => api_token
        )
      end
    end

    def self.badge_name
      "Build Status"
    end

    def self.badge_details(repo, branch)
      {
        "description" => badge_name,
        "image"       => "https://travis-ci.com/#{repo.name}.svg?branch=#{branch}",
        "url"         => "https://travis-ci.com/#{repo.name}"
      }
    end

    attr_reader :repo, :dry_run

    def initialize(repo, dry_run: false, **_)
      @repo    = repo
      @dry_run = dry_run
    end

    def badge_details
      self.class.badge_details(repo, "master")
    end

    def enable
      if dry_run
        puts "** dry-run: travis login --com --github-token $GITHUB_API_TOKEN".light_black
        puts "** dry-run: travis enable --com".light_black
      else
        `travis login --com --github-token $GITHUB_API_TOKEN`
        `travis enable --com`
      end
    end

    def set_env(hash)
      hash.each do |key, value|
        if dry_run
          puts "** dry-run: travis env set #{key} #{value}".light_black
        else
          `travis env set #{key} #{value}`
        end
      end
    end
  end
end
