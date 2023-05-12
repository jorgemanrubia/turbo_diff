require "turbo_diff/version"
require "turbo_diff/engine"

require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

module TurboDiff
  class Engine < ::Rails::Engine
    isolate_namespace TurboDiff

    config.turbo_diff = ActiveSupport::OrderedOptions.new

    config.before_initialize do
      config.turbo_diff.each do |key, value|
        TurboDiff.public_send("#{key}=", value)
      end
    end

    initializer "turbo_diff.assets" do |app|
      if Rails.application.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.precompile += %w[ turbo_diff_manifest ]
      end
    end

    initializer "turbo_diff.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
    end
  end
end
