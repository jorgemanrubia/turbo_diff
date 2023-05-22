import { Selector } from "turbo_diff/selector"
import { DeleteChange } from "turbo_diff/delete_change"
import { InsertChange } from  "turbo_diff/insert_change"
import { ReplaceChange } from  "turbo_diff/replace_change"
import { AttributesChange } from  "turbo_diff/attributes_change"
import { filterElementAndTextNodes } from "turbo_diff/helpers"

export class Changes {
  constructor(fromNode, changes) {
    this.fromNode = fromNode
    this.changes = changes

    this.nodesBySelector = this.groupNodesBySelector(fromNode)
  }

  apply() {
    this.changes.forEach(change => {
      this.applyChange(change)
    })

    return this.fromNode
  }

  // Private

  groupNodesBySelector(rootNode) {
    const nodesBySelector = {};

    function group(node, selector) {
      nodesBySelector[selector] = node

      const children = filterElementAndTextNodes(node.childNodes);
      for (let i = 0; i < children.length; i++) {
        const child = children[i]
        const childSelector = `${selector}/${i}`
        // if(child.setAttribute)
        //   child.setAttribute("data-debug-turbo-diff-selector", childSelector)
        group(child, childSelector)
      }
    }

    group(rootNode, "0")
    return nodesBySelector
  }


  applyChange(change) {
    const selector = new Selector(change.selector)
    const targetNode = this.getNodeBySelector(selector.toString())
    const parentNode = this.getNodeBySelector(selector.parent.toString())

    this.buildChange(change, targetNode, parentNode).apply()
  }

  buildChange(change, targetNode, parentNode) {
    switch (change.type) {
      case "replace":
        return new ReplaceChange(targetNode, change)
      case "insert":
        return new InsertChange(parentNode, change)
      case "delete":
        return new DeleteChange(targetNode, change)
      case "attributes":
        return new AttributesChange(targetNode, change)
    }

    throw `Unknown change type: ${change.type}`
  }

  getNodeBySelector(selector) {
    return this.nodesBySelector[selector]
  }
}
