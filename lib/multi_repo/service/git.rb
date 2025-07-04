require "active_support/core_ext/object/blank"

module MultiRepo::Service
  class Git
    def self.client(path:, clone_source:)
      require "minigit"
      require_relative "git/minigit_capturing_patch"

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

    def self.raw(*args, quiet: false)
      require "minigit"
      require "shellwords"

      command = Shellwords.join(["git", *args])
      command << " &>/dev/null" if quiet && !ENV["GIT_DEBUG"]
      puts "+ #{command}" if ENV["GIT_DEBUG"] # Matches the output of MiniGit

      raise MiniGit::GitError.new(args, $?) unless system(command)
    end

    def self.clone(clone_source:, path:)
      raw("clone", clone_source, path, quiet: true)
    end

    attr_reader :dry_run, :client

    def initialize(path:, clone_source:, dry_run: false)
      require "minigit"

      @dry_run = dry_run
      @client  = self.class.client(path: path, clone_source: clone_source)
    end

    def raw(*args)
      Dir.chdir(client.git_dir) { self.class.raw(*args) }
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
    alias_method :tag?, :branch?

    def remote?(remote)
      client.capturing.remote("show", remote)
    rescue MiniGit::GitError => e
      false
    else
      true
    end

    def destroy_remote(remote)
      if dry_run
        puts "** dry-run: git remote rm #{remote}".light_black
      else
        client.remote("rm", remote)
      end
    rescue MiniGit::GitError
      # Ignore missing remotes because we want them destroyed anyway
      nil
    end

    def remote_branch?(remote, branch)
      client.capturing.ls_remote(remote, branch).present?
    end
  end
end
