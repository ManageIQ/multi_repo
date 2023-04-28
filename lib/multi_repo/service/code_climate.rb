module MultiRepo::Service
  class CodeClimate
    def self.api_token
      @api_token ||= ENV["CODECLIMATE_API_TOKEN"]
    end

    def self.api_token=(token)
      @api_token = token
    end

    def self.badge_name
      "Code Climate"
    end

    def self.badge_details(repo)
      {
        "description" => badge_name,
        "image"       => "https://codeclimate.com/github/#{repo.name}.svg",
        "url"         => "https://codeclimate.com/github/#{repo.name}"
      }
    end

    def self.coverage_badge_name
      "Test Coverage"
    end

    def self.coverage_badge_details(repo)
      {
        "description" => coverage_badge_name,
        "image"       => "https://codeclimate.com/github/#{repo.name}/badges/coverage.svg",
        "url"         => "https://codeclimate.com/github/#{repo.name}/coverage"
      }
    end

    attr_reader :repo, :dry_run

    def initialize(repo, dry_run: false, **_)
      @repo    = repo
      @dry_run = dry_run
    end

    def save!
      write_codeclimate_yaml
      write_rubocop_yamls
    end

    def enable
      ensure_enabled
    end

    def badge_details
      self.class.badge_details(repo)
    end

    def coverage_badge_details
      self.class.coverage_badge_details(repo)
    end

    def test_reporter_id
      ensure_enabled
      @response.dig("data", 0, "attributes", "test_reporter_id")
    end

    def create_repo_secret
      Github.new(dry_run: dry_run).create_or_update_repository_secret(repo.name, "CC_TEST_REPORTER_ID", test_reporter_id)
    end

    private

    def ensure_enabled
      return if @enabled

      require 'rest-client'
      require 'json'

      @response =
        if dry_run
          puts "** dry-run: RestClient.get(\"https://api.codeclimate.com/v1/repos?github_slug=#{repo.name}\", #{headers})".light_black
          {"data" => [{"attributes" => {"badge_token" => "0123456789abdef01234", "test_reporter_id" => "0123456789abcedef0123456789abcedef0123456789abcedef0123456789abc"}}]}
        else
          JSON.parse(RestClient.get("https://api.codeclimate.com/v1/repos?github_slug=#{repo.name}", headers))
        end

      if @response["data"].empty?
        payload = {"data" => {"type" => "repos", "attributes" => {"url" => "https://github.com/#{repo.name}"}}}.to_json
        @response = JSON.parse(RestClient.post("https://api.codeclimate.com/v1/github/repos", payload, headers))
        @response["data"] = [@response["data"]]
      end

      @enabled = true
    end

    def headers
      token = self.class.api_token
      raise "Missing CodeClimate API Token" if token.nil?

      {
        :accept        => "application/vnd.api+json",
        :content_type  => "application/vnd.api+json",
        :authorization => "Token token=#{token}"
      }
    end

    def write_codeclimate_yaml
      write_generator_file(".codeclimate.yml")
    end

    def write_rubocop_yamls
      %w[.rubocop.yml .rubocop_cc.yml .rubocop_local.yml].each do |file|
        write_generator_file(file)
      end
    end

    def write_generator_file(file)
      content = RestClient.get("https://raw.githubusercontent.com/ManageIQ/manageiq/master/lib/generators/manageiq/plugin/templates/#{file}").body
      repo.write_file(file, content, dry_run: dry_run)
    end
  end
end
