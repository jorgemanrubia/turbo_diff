import { Change } from "turbo_diff/change"
import { filterElementAndTextNodes } from "turbo_diff/helpers"

export class InsertChange extends Change {
  constructor(parentNode, change) {
    super(change)
    this.parentNode = parentNode
  }

  apply() {
    super.log("INSERT", this.position, this.parentNode, this.change)

    if(this.childNodes[this.position]) {
      this.childNodes[this.position][this.replaceAction]("afterend", this.replaceContent)
    }
    else {
      this.parentNode[this.replaceAction]("beforeend", this.replaceContent)
    }
  }

  // Private
  get childNodes() {
    return filterElementAndTextNodes(this.parentNode.childNodes)
  }

  get replaceAction() {
    return this.change.text ? "insertAdjacentText" : "insertAdjacentHTML"
  }

  get replaceContent() {
    return this.change.text ? this.change.text : this.change.html
  }

  get position() {
    return this.selector.position
  }
}
