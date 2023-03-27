require 'yaml'

module MultiRepo
  class RepoSet
    def self.config_files
      Dir.glob(MutiRepo.config_dir.join("repo_set*.yml")).sort
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
      @all ||= config.transform_values { |repos| Array(repos).map { |r| Repo.new(r) } }
    end
  end
end
