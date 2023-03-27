module MultiRepo::Helpers
  class UpdateRepoSettings
    attr_reader :repo_name, :github

    def initialize(repo_name, dry_run: false)
      @repo_name = repo_name
      @github    = MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def run
      settings = {
        :has_wiki           => false,
        :has_projects       => false,
        :allow_merge_commit => true,
        :allow_rebase_merge => false,
        :allow_squash_merge => false,
      }

      puts "Editing #{repo_name}"
      github.edit_repository(repo_name, settings)
    end
  end
end
