require "turbo_diff/version"
require "turbo_diff/railtie"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module TurboDiff
  class << self
    def diff(from_html_string, to_html_string)
      Diff.new(from_html_string, to_html_string).changes
    end
  end
end
