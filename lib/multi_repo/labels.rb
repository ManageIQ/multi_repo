module MultiRepo
  class Labels
    def self.config_file
      MultiRepo.config_dir.join("labels.yml")
    end

    def self.config
      @config ||= YAML.unsafe_load_file(config_file)
    end

    def self.[](repo)
      all[repo]
    end

    def self.all
      @all ||= begin
        Array(config["orgs"]).each do |org, options|
          MultiRepo::Service::Github.repo_names_for(org).each do |repo_name|
            next if config.key_path?("repos", repo_name)
            next if options["except"].include?(repo_name)

            config.store_path("repos", repo_name, options["labels"])
          end
        end
        config["repos"].sort.to_h
      end
    end
  end
end
