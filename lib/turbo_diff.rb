require "turbo_diff/version"
require "turbo_diff/engine"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "nokolexbor"

module TurboDiff
  class << self
    def diff(from_html_document_string, to_html_document_string)
      from_html_document = Nokolexbor.HTML(from_html_document_string)
      to_html_document = Nokolexbor.HTML(to_html_document_string)

      Diff.new(from_html_document, to_html_document).changes
    end
  end
end
