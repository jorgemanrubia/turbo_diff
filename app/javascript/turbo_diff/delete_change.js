import { Change } from "turbo_diff/change"

export class DeleteChange extends Change {
  constructor(node, change) {
    super(change)
    this.node = node
  }

  apply() {
    super.log("DELETE", this.node, this.change)
    this.node.parentNode.removeChild(this.node)
  }
}
