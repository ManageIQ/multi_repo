require "multi_repo"

module MultiRepo
  module CLI
    def self.each_repo(**kwargs)
      raise "no block given" unless block_given?

      repos_for(**kwargs).each do |repo|
        puts header(repo.github_repo)
        yield repo
        puts
      end
    end

    def self.repos_for(repo: nil, repo_set: nil, **_)
      Optimist.die("options --repo or --repo_set must be specified") unless repo || repo_set

      if repo
        Array(repo).map { |n| repo_for(n) }
      else
        MultiRepo::RepoSet[repo_set]
      end
    end

    def self.repo_for(repo)
      Optimist.die(:repo, "must be specified") if repo.nil?

      org, repo_name = repo.split("/").unshift(nil).last(2)
      MultiRepo::Repo.new(repo_name, :org => org)
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
