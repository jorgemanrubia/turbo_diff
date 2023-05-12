class TurboDiff::Middleware
  CACHE_EXPIRES_IN = 1.hour

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    status, headers, body = @app.call(env)
    response = ActionDispatch::Response.new(status, headers, body)

    if DiffInterceptor.new(request, response).process
      response.to_a
    else
      [ status, headers, body ]
    end
  end

  private
    class DiffInterceptor
      def initialize(request, response)
        @request = request
        @response = response
      end

      def process
        cache_current_response if cacheable?

        if processable?
          response.content_type = "text/vnd.turbo-diff.json"
          response.body = TurboDiff.diff(cached_response_html, response.body).to_json
          true
        end
      end

      private
        attr_reader :request, :response

        def processable?
          turbo_diff_request? && request_etag.present? && cached_response_html.present?
        end

        def turbo_diff_request?
          @is_turbo_diff_request ||= request.accepts.include?(Mime[:turbo_diff])
        end

        def request_etag
          @request_etag ||= request.if_none_match
        end

        def cached_response_html
          @cached_html ||= Rails.cache.read(cache_key(request_etag))
        end

        def cache_key(etag)
          "#{request.session.id}-#{request.path}-#{etag}"
        end

        def cacheable?
          response_etag.present? && response.successful? && request.get? && response.media_type == "text/html"
        end

        def cache_current_response
          cache_store.write(cache_key(response_etag), response.body, expires_in: CACHE_EXPIRES_IN)
        end

        def response_etag
          @response_etag ||= response.etag
        end

        def cache_store
          @cache_store ||= Rails.cache
        end
    end
end
