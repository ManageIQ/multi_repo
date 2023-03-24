require 'config'

Config.load_and_set_settings(MultiRepo::CONFIG_DIR.join("settings.yml").to_s, MultiRepo::CONFIG_DIR.join("settings.local.yml").to_s)
