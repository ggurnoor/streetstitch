require_relative "boot"

require "rails/all"
require 'dotenv'
Dotenv::Railtie.load


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Streetstitch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Manually add 'lib' to autoload and eager load paths
    lib_path = Rails.root.join("lib")
    config.autoload_paths << lib_path
    config.eager_load_paths << lib_path

    # Ignore specific subdirectories in 'lib' that shouldn't be autoloaded
    %w[assets tasks templates generators middleware].each do |subdir|
      Rails.autoloaders.main.ignore(lib_path.join(subdir))
    end

    # Additional configuration...
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
