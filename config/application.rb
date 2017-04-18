require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UrodParser
  class Application < Rails::Application
    config.autoload_paths += [Rails.root.join('lib')]
    config.eager_load_paths += [Rails.root.join('lib')]
    config.time_zone = 'UTC'
    config.active_record.raise_in_transactional_callbacks = true
  end
end
