require "test_helper"

class DiffTest < ActiveSupport::TestCase
  test "replace root of different type" do
    assert_diff "<root-1></root-1>", "<root-2></root-2>", [
      { type: :replace, selector: "0", html: "<root-2></root-2>" }
    ]
  end

  test "replace only child of different type" do
    from_html = <<-HTML
      <root>
        <child-1></child-1> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-2></child-2> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0", html: "<child-2></child-2>" }
    ]
  end

  test "replace first child of different type" do
    from_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2></child-2> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-3></child-3> 
        <child-2></child-2> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0", html: "<child-3></child-3>" }
    ]
  end

  test "replace last child of different type" do
    from_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2></child-2> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-3></child-3> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/1", html: "<child-3></child-3>" }
    ]
  end

  test "insert missing child at the root" do
    from_html = <<-HTML
      <root>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" }
    ]
  end

  test "insert missing children at the root" do
    from_html = <<-HTML
      <root>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2></child-2> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/1", html: "<child-2></child-2>" }
    ]
  end

  test "insert missing children at the root respecting existing nodes matched by position" do
    from_html = <<-HTML
      <root>
        <child-1></child-1> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2></child-2> 
        <child-3></child-3> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/1", html: "<child-2></child-2>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  private
    def assert_diff(from_html, to_html, expected_changes)
      diff = TurboDiff::Diff.new(from_html, to_html)
      assert_equal expected_changes, diff.changes
    end
end

