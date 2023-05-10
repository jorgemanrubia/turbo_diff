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

  test "insert missing children at the root where it can't match existing nodes by position" do
    from_html = <<-HTML
      <root>
        <child-2></child-2> 
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
      { type: :replace, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/1", html: "<child-2></child-2>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  test "replace 2-level nested nodes" do
    from_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2>
          <target-child></target-child>
        </child-2> 
        <child-3></child-3> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2>
          <child-replaced></child-replaced>
        </child-2> 
        <child-3></child-3> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/1/0", html: "<child-replaced></child-replaced>" },
    ]
  end


  test "insert missing children at the root matching by id" do
    from_html = <<-HTML
      <root>
        <child-2 id="2"></child-2> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1> 
        <child-2 id="2"></child-2> 
        <child-3></child-3> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  test "replace root attributes" do
    from_html = <<-HTML
      <root class="class-1">
      </root>
    HTML

    to_html = <<-HTML
      <root class="class-2">
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :set_attributes, selector: "0", attributes: { class: "class-2" } },
    ]
  end

  test "replace and delete attributes in nested elements" do
    from_html = <<-HTML
    from_html = <<-HTML
      <root>
        <child-1 attribute_1="1" attribute_2="2"></child-1> 
        <child-2 id="2" class="some-class"></child-2> 
        <child-3 attribute-to-delete="please"></child-3> 
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1 attribute_1="a"></child-1> 
        <child-2 id="2" class="some-other-class"></child-2> 
        <child-3></child-3> 
      </root>
    HTML

    assert_diff from_html, to_html, [
      {:type=>:set_attributes, :selector=>"0/0", :attributes=>{:attribute_1=>"a"}, :deleted_attributes=>["attribute_2"]},
      {:type=>:set_attributes, :selector=>"0/1", :attributes=>{:id=>"2", :class=>"some-other-class"}},
      {:type=>:set_attributes, :selector=>"0/2", :deleted_attributes=>["attribute-to-delete"]}
    ]
  end

  private
    def assert_diff(from_html, to_html, expected_changes)
      diff = TurboDiff::Diff.new(from_html, to_html)
      assert_equal expected_changes, diff.changes
    end
end

