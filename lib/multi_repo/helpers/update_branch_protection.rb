module MultiRepo::Helpers
  class UpdateBranchProtection
    attr_reader :repo_name, :branch, :dry_run

    def initialize(repo_name, branch:, dry_run: false, **)
      @repo_name = repo_name
      @branch    = branch
      @github    = MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def run
      puts "Protecting #{branch} branch"

      settings = {
        :enforce_admins                => nil,
        :required_status_checks        => nil,
        :required_pull_request_reviews => nil,
        :restrictions                  => nil
      }

      github.protect_branch(repo_name, branch, settings)
    end
  end
end
