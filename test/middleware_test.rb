require "test_helper"

class MiddlewareTest < ActionDispatch::IntegrationTest
  test "don't intercept regular requests" do
    get posts_path

    assert_response :success
    assert_includes response.content_type, "text/html"
  end

  test "don't intercept turbo requests that contain the turbo-diff header but that doesn't support http caching" do
    get post_path(posts(:hello_world))

    assert_response :success
    assert_includes response.content_type, "text/html"
  end

  test "don't intercept turbo requests that contain the turbo-diff header but that aren't cached" do
    get post_path(posts(:hello_world)), headers: accept_turbo_diff_header

    assert_response :success
    assert_includes response.content_type, "text/html"
  end

  test "intercept turbo requests that contain the turbo-diff header and that are cached" do
    get posts_path
    etag = response.headers["ETag"]

    Post.create! title: "Some new post"

    get posts_path, headers: accept_turbo_diff_header.merge("If-None-Match" => etag)

    assert_response :success
    assert_includes response.content_type, "text/vnd.turbo-diff.json"
  end

  private
    def accept_turbo_diff_header
      { "Accept" => "text/vnd.turbo-diff.json, text/html, application/xhtml+xml" }
    end
end
