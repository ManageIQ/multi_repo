module MultiRepo::Service
  class Github
    def self.api_token
      @api_token ||= ENV["GITHUB_API_TOKEN"]
    end

    def self.api_token=(token)
      @api_token = token
    end

    def self.api_endpoint
      @api_endpoint ||= ENV["GITHUB_API_ENDPOINT"]
    end

    def self.api_endpoint=(endpoint)
      @api_endpoint = endpoint
    end

    def self.client
      @client ||= begin
        raise "Missing GitHub API Token" if api_token.nil?

        params = {
          :api_endpoint  => api_endpoint,
          :access_token  => api_token,
          :auto_paginate => true
        }.compact

        require 'octokit'
        Octokit::Client.new(params)
      end
    end

    def self.repo_names_for(org)
      client
        .list_repositories(org, :type => "sources")
        .reject { |r| r.fork? || r.archived? }
        .map { |r| "#{org}/#{r.name}" }
    end

    def self.create_or_update_repository_secret(repo_name, key, value)
      payload = encode_secret(repo_name, value)
      client.create_or_update_secret(repo_name, key, payload)
    end

    private_class_method def self.encode_secret(repo_name, value)
      require "rbnacl"
      require "base64"

      repo_public_key = client.get_public_key(repo_name)
      decoded_repo_public_key = Base64.decode64(repo_public_key.key)
      public_key = RbNaCl::PublicKey.new(decoded_repo_public_key)
      box = RbNaCl::Boxes::Sealed.from_public_key(public_key)
      encrypted_value = box.encrypt(value)
      encoded_encrypted_value = Base64.strict_encode64(encrypted_value)

      {
        "encrypted_value" => encoded_encrypted_value,
        "key_id"          => repo_public_key.key_id
      }
    end

    attr_reader :dry_run, :client

    def initialize(dry_run: false)
      @dry_run = dry_run
      @client  = self.class.client
    end

    def edit_repository(repo_name, settings)
      if dry_run
        puts "** dry-run: github.edit_repository(#{repo_name.inspect}, #{settings.inspect[1..-2]})".light_black
      else
        client.edit_repository(repo_name, settings)
      end
    end

    def create_label(repo_name, label, color)
      if dry_run
        puts "** dry-run: github.add_label(#{repo_name.inspect}, #{label.inspect}, #{color.inspect})".light_black
      else
        client.add_label(repo_name, label, color)
      end
    end

    def update_label(repo_name, label, color: nil, name: nil)
      settings = {:color => color, :name => name}.compact
      raise ArgumentError, "one of color or name must be passed" if settings.empty?

      if dry_run
        puts "** dry-run: github.update_label(#{repo_name.inspect}, #{label.inspect}, #{settings.inspect[1..-2]})".light_black
      else
        client.update_label(repo_name, label, settings)
      end
    end

    def self.valid_milestone_date?(date)
      !!parse_milestone_date(date)
    end

    def self.parse_milestone_date(date)
      require "active_support/core_ext/time"
      ActiveSupport::TimeZone.new('Pacific Time (US & Canada)').parse(date) # LOL GitHub, TimeZones are hard
    end

    def find_milestone_by_title(repo_name, title)
      client.list_milestones(repo_name, :state => :all).detect { |m| m.title.casecmp?(title) }
    end

    def create_milestone(repo_name, title, due_on)
      if dry_run
        puts "** dry-run: github.create_milestone(#{repo_name.inspect}, #{title.inspect}, :due_on => #{due_on.strftime("%Y-%m-%d").inspect})".light_black
      else
        client.create_milestone(repo_name, title, :due_on => due_on)
      end
    end

    def update_milestone(repo_name, milestone_number, due_on)
      if dry_run
        puts "** dry-run: github.update_milestone(#{repo_name.inspect}, #{milestone_number}, :due_on => #{due_on.strftime("%Y-%m-%d").inspect})".light_black
      else
        client.update_milestone(repo_name, milestone_number, :due_on => due_on)
      end
    end

    def close_milestone(repo_name, milestone_number)
      if dry_run
        puts "** dry-run: github.update_milestone(#{repo_name.inspect}, #{milestone_number}, :state => 'closed')".light_black
      else
        client.update_milestone(repo_name, milestone_number, :state => "closed")
      end
    end

    def protect_branch(repo_name, branch, settings)
      if dry_run
        puts "** dry-run: github.protect_branch(#{repo_name.inspect}, #{branch.inspect}, #{settings.inspect[1..-2]})".light_black
      else
        client.protect_branch(repo_name, branch, settings)
      end
    end
  end
end
