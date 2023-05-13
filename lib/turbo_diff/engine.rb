require "turbo_diff/version"
require "turbo_diff/engine"

module TurboDiff
  class Engine < ::Rails::Engine
    isolate_namespace TurboDiff

    config.turbo_diff = ActiveSupport::OrderedOptions.new

    config.before_initialize do
      config.turbo_diff.each do |key, value|
        TurboDiff.public_send("#{key}=", value)
      end
    end

    initializer "turbo_diff.middleware" do |app|
      app.config.middleware.use TurboDiff::Middleware
    end

    initializer "turbo_diff.mimetype" do
      Mime::Type.register "text/vnd.turbo-diff.json", :turbo_diff
    end

    initializer "turbo_diff.assets" do |app|
      app.config.assets.paths << root.join("app/javascript")
    end

    initializer "turbo_diff.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
    end
  end
end
