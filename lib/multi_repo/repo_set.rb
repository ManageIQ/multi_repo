require 'yaml'

module MultiRepo
  class RepoSet
    def self.repo_set_files
      Dir.glob(config_dir.join("repo_set*.yml")).sort
    end

    def self.[](set_name)
      all[set_name]
    end

    def self.all
      @all ||=
        repo_set_files.each_with_object({}) do |f, h|
          YAML.unsafe_load_file(f).each do |set_name, repos|
            h[set_name] = Array(repos).map { |r| Repo.new(r) }
          end
        end
    end
  end
end
