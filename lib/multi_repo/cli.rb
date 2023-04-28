require "multi_repo"
require "optimist"
require "colorize"

module MultiRepo
  module CLI
    def self.each_repo(**kwargs)
      raise "no block given" unless block_given?

      repos_for(**kwargs).each do |repo|
        puts header(repo.name)
        yield repo
        puts
      end
    end

    def self.repos_for(repo: nil, repo_set: nil, dry_run: false, **_)
      Optimist.die("options --repo or --repo_set must be specified") unless repo || repo_set

      if repo_set
        repos = MultiRepo::RepoSet[repo_set]&.deep_dup
        Optimist.die(:repo_set, "#{repo_set.inspect} was not found in the config") if repos.nil?

        if repo
          repo_names = Set.new(Array(repo))
          repos.select! { |r| repo_names.include?(r.name) }
        end

        repos.each { |r| r.dry_run = dry_run }

        repos
      else
        Array(repo).map { |n| MultiRepo::Repo.new(n, dry_run: dry_run) }
      end
    end

    def self.repo_for(repo_name, repo_set: nil, dry_run: false)
      Optimist.die(:repo, "must be specified") if repo_name.nil?

      repos_for(repo: repo_name, repo_set: repo_set, dry_run: dry_run).first
    end

    def self.common_options(optimist, only: %i[repo repo_set dry_run], except: nil, repo_set_default: "master")
      optimist.banner("")
      optimist.banner("Common Options:")

      subset = Array(only).map(&:to_sym) - Array(except).map(&:to_sym)

      if subset.include?(:repo_set)
        optimist.opt :repo_set, "The repo set to work with", :type => :string, :default => repo_set_default, :short => "s"
      end
      if subset.include?(:repo)
        msg = "Individual repo(s) to work with"
        if subset.include?(:repo_set)
          sub_opts = {}
          msg << "; Overrides --repo-set"
        else
          sub_opts = {:required => true}
        end
        optimist.opt :repo, msg, sub_opts.merge(:type => :strings)
      end
      if subset.include?(:dry_run)
        optimist.opt :dry_run, "Execute without making changes", :default => false
      end
    end

    #
    # Logging helpers
    #

    HEADER_SIZE = 80

    def self.header(title, char = "=")
      title = " #{title} "
      start = (HEADER_SIZE / 2) - (title.length / 2)
      separator(char).tap { |h| h[start, title.length] = title }
    end

    def self.separator(char = "*")
      char * HEADER_SIZE
    end

    def self.progress_bar(total = 100)
      require "progressbar"
      ProgressBar.create(
        :format => "%j%% |%B| %E",
        :length => HEADER_SIZE,
        :total  => total
      )
    end
  end
end
