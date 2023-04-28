require 'yaml'

module MultiRepo
  class RepoSet
    def self.config_files
      Dir.glob(MultiRepo.config_dir.join("repos*.yml")).sort
    end

    def self.config
      @config ||= config_files.each_with_object({}) do |f, h|
        h.merge!(YAML.unsafe_load_file(f))
      end
    end

    def self.[](set_name)
      all[set_name]
    end

    def self.all
      @all ||= config.transform_values do |repo_set|
        repo_set.map do |repo, config|
          Repo.new(repo, config: config)
        end
      end
    end
  end
end
