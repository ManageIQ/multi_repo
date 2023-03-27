module MultiRepo::Helpers
  class UpdateLabels
    attr_reader :repo_name, :expected_labels, :github

    def initialize(repo_name, dry_run: false)
      @repo_name       = repo_name
      @expected_labels = MultiRepo::Labels[repo_name]
      @github          = MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def run
      if expected_labels.nil?
        puts "!! No labels defined for #{repo_name}"
        return
      end

      expected_labels.each do |label, color|
        github_label = existing_labels.detect { |l| l.name == label }

        if !github_label
          puts "Creating #{label.inspect} with #{color.inspect}"
          github.create_label(repo_name, label, color)
        elsif github_label.color.downcase != color.downcase
          puts "Updating #{label.inspect} to #{color.inspect}"
          github.update_label(repo_name, label, color)
        end
      end
    end

    private def existing_labels
      @existing_labels ||= github.client.labels(repo_name)
    end
  end
end
