require "test_helper"

class MiddlewareTest < ActionDispatch::IntegrationTest
  test "don't intercept regular requests" do
    get posts_path

    assert_response :success
    assert_includes response.content_type, "text/html"
  end

  test  "don't intercept turbo requests that contain the turbo-diff header but that doesn't support http caching" do
    get post_path(posts(:hello_world))

    assert_response :success
    assert_includes response.content_type, "text/html"
  end
end
