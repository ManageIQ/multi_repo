module MultiRepo::Service
  class Git
    def self.client(path:, clone_source:)
      require "minigit"

      retried = false
      MiniGit.debug = true if ENV["GIT_DEBUG"]
      MiniGit.new(path)
    rescue ArgumentError => err
      raise if retried
      raise unless err.message.include?("does not seem to exist")

      clone(clone_source: clone_source, path: path)
      retried = true
      retry
    end

    def self.clone(clone_source:, path:)
      require "minigit"
      require "shellwords"

      args = ["clone", clone_source, path]
      command = Shellwords.join(["git", *args])
      command << " &>/dev/null" unless ENV["GIT_DEBUG"]
      puts "+ #{command}" if ENV["GIT_DEBUG"] # Matches the output of MiniGit

      raise MiniGit::GitError.new(args, $?) unless system(command)
    end

    attr_reader :dry_run, :client

    def initialize(path:, clone_source:, dry_run: false)
      @dry_run = dry_run
      @client  = self.class.client(path: path, clone_source: clone_source)
    end

    def fetch(output: false)
      client = output ? self.client : self.client.capturing

      client.fetch(:all => true, :tags => true)
    end

    def hard_checkout(branch, source = "origin/#{branch}", output: false)
      client = output ? self.client : self.client.capturing

      client.reset(:hard => true)
      client.clean("-xdf")
      client.checkout("-B", branch, source)
    end

    def destroy_tag(tag, output: false)
      client = output ? self.client : self.client.capturing

      if dry_run
        puts "** dry-run: git tag --delete #{tag}".light_black
      else
        client.tag({:delete => true}, tag)
      end
    rescue MiniGit::GitError
      # Ignore missing tags because we want them destroyed anyway
      nil
    end

    def branch?(branch)
      client.capturing.rev_parse("--verify", branch)
    rescue MiniGit::GitError
      false
    else
      true
    end

    def remote?(remote)
      client.capturing.remote("show", remote)
    rescue MiniGit::GitError => e
      false
    else
      true
    end

    def remote_branch?(remote, branch)
      client.capturing.ls_remote(remote, branch).present?
    end
  end
end
