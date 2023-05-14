import {Change} from "turbo_diff/change"

export class AttributesChange extends Change {
  constructor(node, change) {
    super(change)
    this.node = node
  }

  apply() {
    super.log("ATTRIBUTES", this.node, this.change)

    this.processAdded()
    this.processDeleted()
  }

  // Private

  processAdded() {
    if (this.change.added) {
      for (const key in this.change.added) {
        this.node.setAttribute(key, this.change.added[key])
      }
    }
  }

  processDeleted() {
    if (this.change.deleted) {
      for (const key in this.change.deleted) {
        this.node.removeAttribute(key)
      }
    }
  }
}
