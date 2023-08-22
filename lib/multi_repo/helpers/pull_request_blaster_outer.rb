require 'pathname'

module MultiRepo::Helpers
  class PullRequestBlasterOuter
    attr_reader :repo, :base, :head, :script, :dry_run, :message, :title

    def initialize(repo, base:, head:, script:, dry_run:, message:, title: nil, **)
      @repo    = repo
      @base    = base
      @head    = head
      @script  = begin
        s = Pathname.new(script)
        s = Pathname.new(Dir.pwd).join(script) if s.relative?
        raise "File not found #{s}" unless s.exist?
        s.to_s
      end
      @dry_run = dry_run
      @message = message
      @title   = (title || message)[0, 72]
    end

    def blast
      puts "+++ blasting #{repo.name}..."

      repo.git.fetch

      unless repo.git.remote_branch?("origin", base)
        puts "!!! Skipping #{repo.name}: 'origin/#{base}' not found"
        return
      end

      repo.git.hard_checkout(head, "origin/#{base}")
      run_script

      result = false
      if !commit_changes
        puts "!!! Failed to commit changes. Perhaps the script is wrong or #{repo.name} is already updated."
      elsif dry_run
        result = "Committed but is dry run"
      else
        puts "Do you want to open a pull request on #{repo.name} with the above changes? (Y/N)"
        answer = $stdin.gets.chomp
        if answer.upcase.start_with?("Y")
          fork_repo unless forked?
          push_branch
          result = open_pull_request
        end
      end
      puts "--- blasting #{repo.name} complete"
      result
    end

    private

    def github
      @github ||= MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def forked?
      github.client.repos(github.client.login).any? { |m| m.name.split("/").last == repo.name.split("/").last }
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
        parts = []
        parts << "GITHUB_REPO=#{repo.name}"
        parts << "DRY_RUN=true" if dry_run
        parts << script
        cmd = parts.join(" ")

        unless system(cmd)
          puts "!!! Script execution failed."
          exit $?.exitstatus
        end
      end
    end

    def commit_changes
      repo.chdir do
        begin
          repo.git.client.add("-v", ".")
          repo.git.client.commit("-m", message)
          repo.git.client.show
          if dry_run
            puts "!!! --dry-run enabled: If the above commit in #{repo.path} looks good, run again without dry run to fork the repo, push the branch and open a pull request."
          end
          true
        rescue MiniGit::GitError => e
          e.status.exitstatus == 0
        end
      end
    end

    def origin_remote
      "pr_blaster_outer"
    end

    def origin_url
      "git@github.com:#{github.client.login}/#{repo.name.split("/").last}.git"
    end

    def pr_head
      "#{github.client.login}:#{head}"
    end

    def push_branch
      repo.chdir do
        repo.git.client.remote("add", origin_remote, origin_url) unless repo.git.remote?(origin_remote)
        repo.git.client.push("-f", origin_remote, "#{head}:#{head}")
      end
    end

    def open_pull_request
      pr = github.client.create_pull_request(repo.name, base, pr_head, title, title)
      pr.html_url
    rescue => err
      raise unless err.message.include?("A pull request already exists")
      puts "!!! Skipping.  #{err.message}"
    end
  end
end
