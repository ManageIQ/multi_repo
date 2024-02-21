module MultiRepo::Helpers
  class UpdateMilestone
    attr_reader :repo_name, :title, :due_on, :close, :github

    def initialize(repo_name, title:, due_on:, close:, dry_run: false, **)
      raise ArgumentError, "due_on must be specified" if due_on.nil? && !close

      @repo_name = repo_name
      @title     = title
      @due_on    = MultiRepo::Service::Github.parse_milestone_date(due_on) if due_on
      @close     = close
      @github    = MultiRepo::Service::Github.new(dry_run: dry_run)
    end

    def run
      existing = github.find_milestone_by_title(repo_name, title)

      if close
        if existing
          puts "Closing milestone #{title.inspect} (#{existing.number})"
          github.close_milestone(repo_name, existing.number)
        end
        return
      end

      due_on_str = due_on.strftime("%Y-%m-%d").inspect

      if existing
        puts "Updating milestone #{title.inspect} (#{existing.number}) with due date #{due_on_str}"
        github.update_milestone(repo_name, existing.number, due_on)
      else
        puts "Creating milestone #{title.inspect} with due date #{due_on_str}"
        github.create_milestone(repo_name, title, due_on)
      end
    end
  end
end
