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
  end
end
