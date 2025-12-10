require 'pathname'

module MultiRepo::Helpers
  class PullRequestBlasterOuter
    attr_reader :repo, :base, :head, :script, :dry_run, :source_message, :source_title, :source_body, :force

    def initialize(repo, base:, head:, script:, dry_run:, message:, title: nil, body: nil, force: false, **)
      @repo    = repo
      @base    = base
      @head    = head
      @script  = begin
        s = Pathname.new(script).expand_path
        raise "File not found #{s}" unless s.exist?
        s.to_s
      end
      @dry_run = dry_run
      @force   = force

      @source_message = message&.gsub("\\n", "\n")
      @source_title   = title
      @source_body    = body&.gsub("\\n", "\n")
    end

    def blast
      repo.git.fetch

      unless repo.git.remote_branch?("origin", base)
        puts "!! Skipping #{repo.name}: 'origin/#{base}' not found".light_yellow
        return
      end

      repo.git.hard_checkout(head, "origin/#{base}")
      run_script

      result = false
      if !changes_found?
        puts
        puts "!! Skipping #{repo.name}: No changes found".light_yellow
        result = "no changes".light_yellow
      else
        commit_changes
        show_commit
        puts

        if dry_run
          puts "** dry-run: Skipping opening pull request. The pull request would look like:".light_black
          puts
          puts "Pull Request Title:".light_black
          puts title.light_black
          puts
          puts "Pull Request Body:".light_black
          puts body.light_black

          result = "dry run".light_black
        else
          answer =
            if force
              "Y"
            else
              print "Do you want to open a pull request on #{repo.name} with the above changes? (y/N): "
              $stdin.gets.chomp
            end

          if answer.upcase.start_with?("Y")
            fork_repo unless forked?
            push_branch
            result = open_pull_request
          else
            puts "!! Skipping #{repo.name}: User ignored".light_yellow
            result = "ignored".light_yellow
          end
        end
      end
      result
    end

    private

    attr_accessor :override_message

    def message
      override_message || source_message
    end

    def title
      source_title || message.lines.first.chomp[0, 72]
    end

    def body
      source_body || message.lines.drop(1).join.strip
    end

    def github
      @github ||= MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def forked?
      # NOTE: There is an assumption here that the fork's name will match the source's name.
      #   Ideally there would be a "forked from" field in the repo metadata, but there isn't.
      github.client.repos(github.client.login, :type => "forks").any? { |m| m.name == repo.short_name }
    end

    def fork_repo
      github.client.fork(repo.name)
      until forked?
        print "."
        sleep 3
      end
    end

    def run_script
      repo.chdir do
        Bundler.with_unbundled_env do
          # Ensure any previous override commit message is removed
          FileUtils.rm_f(".git/COMMIT_EDITMSG")
          self.override_message = nil

          parts = []
          parts << "GITHUB_REPO=#{repo.name}"
          parts << "DRY_RUN=true" if dry_run
          parts << script
          cmd = parts.join(" ")

          unless system(cmd)
            puts "!! Script execution failed.".light_red
            exit $?.exitstatus
          end

          if File.exist?(".git/COMMIT_EDITMSG")
            self.override_message = File.read(".git/COMMIT_EDITMSG")
          end
        end
      end
    end

    def changes_found?
      repo.git.client.capturing.status("--porcelain").chomp.present?
    end

    def commit_changes
      repo.git.client.add("-v", ".")
      repo.git.client.commit("-m", message)
    end

    def show_commit
      if force
        repo.git.raw("--no-pager", "show")
      else
        repo.git.client.show
      end
    end

    def blast_remote
      "pr_blaster_outer"
    end

    def blast_remote_url
      # NOTE: Similar to `forked?`, there is an assumption here that the fork's name will match the source's name.
      "git@github.com:#{github.client.login}/#{repo.short_name}.git"
    end

    def pr_head
      "#{github.client.login}:#{head}"
    end

    def push_branch
      repo.git.client.remote("add", blast_remote, blast_remote_url) unless repo.git.remote?(blast_remote)
      repo.git.client.push("-f", blast_remote, "#{head}:#{head}")
    end

    def open_pull_request
      pr = github.client.create_pull_request(repo.name, base, pr_head, title, body)
      pr.html_url
    rescue => err
      raise unless err.message.include?("A pull request already exists")
      puts "!! Skipping #{repo.name}: #{err.message}".light_yellow
    end
  end
end
