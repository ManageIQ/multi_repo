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
  end
end
