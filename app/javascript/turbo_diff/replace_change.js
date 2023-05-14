import {Change} from "turbo_diff/change"

export class ReplaceChange extends Change {
  constructor(node, change) {
    super(change)
    this.node = node
  }

  apply() {
    super.log("REPLACE", this.node, this.change)

    const newElement = this.change.html ? this.buildHtmlNode() : this.buildTextNode()

    this.node.parentNode.replaceChild(newElement, this.node)
  }

  // Private

  buildHtmlNode() {
    const template = document.createElement('template')
    template.innerHTML = this.change.html
    return template.content.childNodes[0]
  }

  buildTextNode() {
    return document.createTextNode(this.change.text)
  }
}
