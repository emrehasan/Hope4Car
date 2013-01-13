raw_config = File.read(Rails.root.join('config','app_config.yml'))
APP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys