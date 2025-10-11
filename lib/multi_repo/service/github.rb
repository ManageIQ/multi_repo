require 'active_support/core_ext/module/delegation'

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

    FETCH_ACTIONS=%i[list_repositories list_milestones org_members org_teams team_members workflows get_actions_public_key]
    def self.client
      @client ||= begin
        raise "Missing GitHub API Token" if api_token.nil?

        params = {
          :api_endpoint  => api_endpoint,
          :access_token  => api_token,
          :auto_paginate => true
        }.compact

        require 'octokit'

        if ENV["DEBUG"]
          middleware = Octokit.middleware.dup
          middleware.response :logger
          Octokit.middleware = middleware
        end

        c = Octokit::Client.new(params)
        dry_run ? DryRunner.new(c, "github", FETCH_ACTIONS) : c
      end
    end

    def self.org_repo_names(org, include_forks: false, include_archived: false)
      repos = client.list_repositories(org, :type => "sources")
      repos.reject!(&:fork?) unless include_forks
      repos.reject!(&:archived?) unless include_archived
      repos.map(&:full_name).sort
    end

    def self.valid_milestone_date?(date)
      !!parse_milestone_date(date)
    end

    def self.parse_milestone_date(date)
      require "active_support/core_ext/time"
      ActiveSupport::TimeZone.new('Pacific Time (US & Canada)').parse(date) # LOL GitHub, TimeZones are hard
    end

    def self.find_milestone_by_title(repo_name, title)
      client.list_milestones(repo_name, :state => :all).detect { |m| m.title.casecmp?(title) }
    end

    def self.org_member_names(org)
      client.org_members(org).map(&:login).sort_by(&:downcase)
    end

    def self.find_team_by_name(org, team)
      client.org_teams(org).detect { |t| t.slug == team }
    end

    def self.team_members(org, team)
      team_id = find_team_by_name(org, team)&.id
      team_id ? client.team_members(team_id) : []
    end

    def self.team_member_names(org, team)
      team_members(org, team).map(&:login).sort_by(&:downcase)
    end

    def self.team_ids_by_name(org)
      @team_ids_by_name ||= {}
      @team_ids_by_name[org] ||= client.org_teams(org).map { |t| [t.slug, t.id] }.sort.to_h
    end

    def self.team_names(org)
      team_ids_by_name(org).keys
    end

    def self.disabled_workflows(repo_name)
      client.workflows(repo_name)[:workflows].select { |w| w.state == "disabled_inactivity" }
    end

    PR_REGEX = %r{^([^/#]+/[^/#]+)#(\d+)$}

    # Parse a list of PRs that are in URL or org/repo#pr format into a Array of
    # [repo_name, pr_number] entries.
    def self.parse_prs(*prs)
      prs.flatten.map do |pr|
        # Normalize to org/repo#pr
        normalized_pr = pr.sub("https://github.com/", "").sub("/pull/", "#")

        if (match = PR_REGEX.match(normalized_pr))
          repo_name, pr_number = match.captures
          [repo_name, pr_number.to_i]
        else
          raise ArgumentError, "Invalid PR '#{pr}'. PR must be a GitHub URL or in org/repo#pr format."
        end
      end
    end

    attr_reader :dry_run

    def initialize(dry_run: false)
      require "octokit"

      @dry_run = dry_run
    end

    delegate :client,
             :org_repo_names,
             :find_milestone_by_title,
             :org_member_names,
             :find_team_by_name,
             :team_members,
             :team_member_names,
             :team_ids_by_name,
             :team_names,
             :disabled_workflows,
             :to => :class

    def edit_repository(repo_name, settings)
      client.edit_repository(repo_name, settings)
    end

    def create_label(repo_name, label, color)
      client.add_label(repo_name, label, color)
    end

    def update_label(repo_name, label, color: nil, name: nil)
      settings = {:color => color, :name => name}.compact
      raise ArgumentError, "one of color or name must be passed" if settings.empty?

      client.update_label(repo_name, label, settings)
    end

    def delete_label!(repo_name, label)
      client.delete_label!(repo_name, label)
    end

    def add_labels_to_an_issue(repo_name, issue_number, labels)
      labels = Array(labels)
      client.add_labels_to_an_issue(repo_name, issue_number, labels)
    end

    def remove_labels_from_an_issue(repo_name, issue_number, labels)
      Array(labels).each do |label|
        client.remove_label(repo_name, issue_number, label)
      rescue Octokit::NotFound
        # Ignore labels that are not found, because we want them removed anyway
      end
    end

    def add_comment(repo_name, issue_number, body)
      client.add_comment(repo_name, issue_number, body)
    end

    def assign_user(repo_name, issue_number, assignee)
      assignee = assignee[1..] if assignee.start_with?("@")
      client.update_issue(repo_name, issue_number, "assignee" => assignee)
    end

    def create_milestone(repo_name, title, due_on)
      client.create_milestone(repo_name, title, :due_on => due_on)
    end

    def update_milestone(repo_name, milestone_number, due_on)
      client.update_milestone(repo_name, milestone_number, :due_on => due_on)
    end

    def close_milestone(repo_name, milestone_number)
      client.update_milestone(repo_name, milestone_number, :state => "closed")
    end

    def protect_branch(repo_name, branch, settings)
      client.protect_branch(repo_name, branch, settings)
    end

    def add_team_membership(org, team, user)
      team_id = team_ids_by_name(org)[team]

      client.add_team_membership(team_id, user)
    end

    def remove_team_membership(org, team, user)
      team_id = team_ids_by_name(org)[team]

      client.remove_team_membership(team_id, user)
    end

    def remove_collaborator(repo_name, user)
      client.remove_collaborator(repo_name, user)
    end

    def enable_workflow(repo_name, workflow_number)
      command = "repos/#{repo_name}/actions/workflows/#{workflow_number}/enable"

      client.put(command)
    end

    def merge_pull_request(repo_name, pr_number)
      client.merge_pull_request(repo_name, pr_number)
    end

    def create_or_update_repository_secret(repo_name, key, value)
      payload = encode_secret(repo_name, value)

      client.create_or_update_actions_secret(repo_name, key, payload)
    end

    private def encode_secret(repo_name, value)
      raise ArgumentError, "value to encode cannot be nil" if value.nil?

      require "rbnacl"
      require "base64"

      repo_public_key = client.get_actions_public_key(repo_name)
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
