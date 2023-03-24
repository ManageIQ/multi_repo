require 'config'

Config.load_and_set_settings(MultiRepo.config_dir.join("settings.yml").to_s, MultiRepo.config_dir.join("settings.local.yml").to_s)
