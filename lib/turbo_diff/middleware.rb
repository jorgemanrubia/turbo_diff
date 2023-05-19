class TurboDiff::Middleware
  CACHE_EXPIRES_IN = 1.hour
  TURBO_DIFF_MIME_TYPE = "text/vnd.turbo-diff.json"

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
          convert_into_turbo_diff_response
          true
        end
      end

      private
        attr_reader :request, :response

        def processable?
          turbo_diff_request? && request.get? && request_etag.present? && cached_response_html.present?
        end

        def turbo_diff_request?
          @is_turbo_diff_request ||= request.accepts.include?(Mime[:turbo_diff])
        end

        def request_etag
          @request_etag ||= request.if_none_match || request.headers["Turbo-Etag"]
        end

        def cached_response_html
          Rails.logger.info "READING FROM #{cache_key(request_etag)}"
          @cached_html ||= Rails.cache.read(cache_key(request_etag))
        end

        def cache_key(etag)
          "#{request.session.id}-#{request.path}-#{etag}"
        end

        def convert_into_turbo_diff_response
          response.content_type = TURBO_DIFF_MIME_TYPE
          response.body = calculate_diff.to_json
          response.cache_control[:no_store] = true
        end

        def calculate_diff
          result = nil
          string_1 = cached_response_html
          string_2 = response.body
          total_time = Benchmark.realtime { result = TurboDiff.diff(string_1, string_2) }
          Rails.logger.info("Diff time: #{total_time}")
          result
        end

        def cacheable?
          response_etag.present? && response.successful? && request.get? && response.media_type == "text/html"
        end

        def cache_current_response
          Rails.logger.info "WRITING TO #{cache_key(response_etag)}"

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
