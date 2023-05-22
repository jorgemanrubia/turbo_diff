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
        <child-2>Child 2 contents</child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1>
        <child-2>Child 2 contents</child-2>
        <child-3></child-3>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  test "insert missing children at the root where it can match existing nodes by type and attributes" do
    from_html = <<-HTML
      <root>
        <child data-attribute="value"></child>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child></child>
        <child data-attribute="value">Child contents</child>
        <child></child>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0/0", text: "Child contents" },
      { type: :insert, selector: "0/0", html: "<child></child>" },
      { type: :insert, selector: "0/2", html: "<child></child>" }
    ]
  end

  test "delete children at the root where it can match existing nodes by type and attributes" do
    from_html = <<-HTML
      <root>
        <child data-attribute="value">Child contents</child>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child></child>
        <child data-attribute="value"></child>
        <child></child>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/0/0" },
      { type: :insert, selector: "0/0", html: "<child></child>" },
      { type: :insert, selector: "0/2", html: "<child></child>" }
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
      { type: :replace, selector: "0/1/0", html: "<child-replaced></child-replaced>" }
    ]
  end


  test "insert missing children at the root matching by id" do
    from_html = <<-HTML
      <root>
        <child-2 id="2">Child 2 content</child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1>
        <child-2 id="2">Child 2 content</child-2>
        <child-3></child-3>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  test "insert missing children at the root matching by id considering content" do
    from_html = <<-HTML
      <root>
        <child-2 id="2">Child 2 content</child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1>
        <child-2 id="2">Child 2 content</child-2>
        <child-3></child-3>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  test "insert missing children and replacing attributes" do
    from_html = <<-HTML
      <root>
        <child-2 id="2">Child 2 content</child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root data-new="attribute">
        <child-1></child-1>
        <child-2 id="2">Child 2 content</child-2>
        <child-3></child-3>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :attributes, selector: "0", added: { "data-new": "attribute" } },
      { type: :insert, selector: "0/0", html: "<child-1></child-1>" },
      { type: :insert, selector: "0/2", html: "<child-3></child-3>" }
    ]
  end

  test "replace node text matching by id" do
    from_html = <<-HTML
      <root>
        <child-2 id="2">Child 2 content</child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-2 id="2">Child 2 new content</child-2>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0/0", text: "Child 2 new content" }
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
      { type: :attributes, selector: "0", added: { class: "class-2" } }
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
      { type: :attributes, selector: "0/1", added: { id: "2", class: "some-other-class" } },
      { type: :attributes, selector: "0/0", added: { attribute_1: "a" }, deleted: [ "attribute_2" ] },
    { type: :attributes, selector: "0/2", deleted: [ "attribute-to-delete" ] }
    ]
  end

  test "delete elements in the root node" do
    from_html = <<-HTML
      <root>
        <child-1></child-1>
        <child-2></child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-1></child-1>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/1" }
    ]
  end

  test "delete elements matching by id" do
    from_html = <<-HTML
      <root>
        <child-1 id="1"></child-1>
        <child-2 id="2"></child-2>
        <child-3 id="3"></child-3>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-3 id="3"></child-3>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/0" },
      { type: :delete, selector: "0/1" }
    ]
  end

  test "delete and insert elements matching by id" do
    from_html = <<-HTML
      <root>
        <child-1 id="1"></child-1>
        <child-2 id="2"></child-2>
        <child-3 id="3"></child-3>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-3 id="3"></child-3>
        <child-4 id="4"></child-4>
        <child-5 id="5"></child-5>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/0" },
      { type: :delete, selector: "0/1" },
      { type: :insert, selector: "0/1", "html"=>%(<child-4 id="4"></child-4>) },
      { type: :insert, selector: "0/2", "html"=>%(<child-5 id="5"></child-5>) }
    ]
  end

  test "delete and insert elements matching by id with leading unmatching element" do
    from_html = <<-HTML
      <root>
        <child-a></child-a>
        <child-1 id="1"></child-1>
        <child-2 id="2"></child-2>
        <child-3 id="3"></child-3>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-b></child-b>
        <child-3 id="3"></child-3>
        <child-4 id="4"></child-4>
        <child-5 id="5"></child-5>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/1" },
      { type: :delete, selector: "0/2" },
      { type: :replace, selector: "0/0", html: "<child-b></child-b>" },
      { type: :insert, selector: "0/2", html: %(<child-4 id="4"></child-4>) },
      { type: :insert, selector: "0/3", html: %(<child-5 id="5"></child-5>) }
    ]
  end

  test "delete and replace elements" do
    from_html = <<-HTML
      <root>
        <child-1></child-1>
        <child-2></child-2>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child-2></child-2>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/0" }
    ]
  end

  test "delete and replace elements matching by equality" do
    from_html = <<-HTML
      <root>
        <child data-1="v1"></child>
        <child data-3="v3">
          <child data-3_1="v31">
          </child>
        </child>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <child data-1="v1"></child>
        <child data-2="v2"></child>
        <child data-3="v3">
          <child data-3_1="v31_changed"></child>
        </child>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :attributes, selector: "0/1/0", added: { "data-3_1" => "v31_changed" } },
      { type: :insert, selector: "0/1", html: %(<child data-2="v2"></child>) }
    ]
  end

  test "update text in root element" do
    from_html = <<-HTML
      <root>
        hola
      </root>
    HTML

    to_html = <<-HTML
      <root>
        adios
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0", text: "adios" }
    ]
  end

  test "update text and elements nodes in root element" do
    from_html = <<-HTML
      <root>
        hola
        <br>
        jorge
      </root>
    HTML

    to_html = <<-HTML
      <root>
        adios
        <br>
        jorge
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0", text: "adios" }
    ]
  end

  test "update text and elements nodes in root element with initial match" do
    from_html = <<-HTML
      <root>
        I am reading
        <br>
        Dune
      </root>
    HTML

    to_html = <<-HTML
      <root>
        I am reading
        <br>
        The Lord of the Rings
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/2", text: "The Lord of the Rings" }
    ]
  end

  test "delete text nodes" do
    from_html = <<-HTML
      <root>
        I am reading
        <br>
        Dune
      </root>
    HTML

    to_html = <<-HTML
      <root>
        I am reading
        <br>
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :delete, selector: "0/2" }
    ]
  end

 test "support doctype in HTML declaration" do
    from_html = <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Old title</title>
        </head>
        <body>
        </body>
      </html>
    HTML

   to_html = <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>New title</title>
        </head>
        <body>
        </body>
      </html>
   HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0/0/0", text: "New title" }
    ]
  end

  test "replace an element with text" do
    from_html = <<-HTML
      <root>
        <p>Hola</p>
      </root>
    HTML

    to_html = <<-HTML
      <root>
        Adios
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0", text: "Adios" }
    ]
  end

  test "ignore ignorable elements" do
    from_html = <<-HTML
      <root>
        <foo data-turbo-diff-ignore></foo>
        <p>Hola</p>
        <input name="authenticity_token" type="hidden" value="123">
      </root>
    HTML

    to_html = <<-HTML
      <root>
        <bar data-turbo-diff-ignore></bar>
        <p>Adios</p>
        <input name="authenticity_token" type="hidden" value="789">
      </root>
    HTML

    assert_diff from_html, to_html, [
      { type: :replace, selector: "0/0/0", text: "Adios" }
    ]
  end

  # test "from middleware" do
  #   out_folder = "/Users/jorge/Work/basecamp/turbo_diff/test/fixtures/files"
  #   from_html = File.read(File.join(out_folder, "from.html"))
  #   to_html = File.read(File.join(out_folder, "to.html"))
  #
  #   assert_diff from_html, to_html, []
  # end

  private
    def assert_diff(from_html_string, to_html_string, expected_changes)
      from_html, to_html = parse_html(from_html_string), parse_html(to_html_string)
      changes = TurboDiff::Diff.new(from_html, to_html).changes
      assert_changes expected_changes, changes.as_json
    end
end
