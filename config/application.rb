require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module RailsTodo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.generators.helper      = false
    config.autoload_paths += %W(#{config.root}/lib)

    ENV.update YAML.load_file('config/application.yml')[Rails.env] rescue {}
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.i18n.default_locale = :ja # デフォルトのlocaleを日本語(:ja)にする
    config.time_zone = 'Tokyo'
    config.filter_parameters += [:client_secret, :client_id]
    # config.active_record.default_timezone = :local
    config.paths.add 'lib', eager_load: true
  end
end
