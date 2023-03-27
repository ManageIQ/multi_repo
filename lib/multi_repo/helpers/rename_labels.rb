module MultiRepo::Helpers
  class RenameLabels
    attr_reader :repo_name, :rename_hash, :github

    def initialize(repo_name, rename_hash, dry_run: false)
      @repo_name   = repo_name
      @rename_hash = rename_hash
      @github      = MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def run
      rename_hash.each do |old_name, new_name|
        github_label = existing_labels.detect { |l| l.name == old_name }

        if github_label
          puts "Renaming label #{old_name.inspect} to #{new_name.inspect}"
          github.update_label(repo_name, old_name, name: new_name)
        end
      end
    end

    private def existing_labels
      @existing_labels ||= github.labels(repo_name)
    end
  end
end
