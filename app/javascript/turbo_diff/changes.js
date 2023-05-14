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

  // replace(html, targetNode, text) {
  //   if (html) {
  //     this.replaceNode(targetNode, html)
  //   } else if (text) {
  //     this.replaceNodeWithText(targetNode, text)
  //   }
  // }
  //
  // insert(html, targetNode, text) {
  //   if (html) {
  //     this.insertNode(targetNode, html)
  //   } else if (text) {
  //     this.insertNodeWithText(targetNode, text)
  //   }
  // }
  //
  //
  // replaceNode(targetNode, html) {
  //   const newNodes = this.createNodesFromHTML(html)
  //   const parent = targetNode.parentNode
  //
  //   newNodes.forEach(newNode => {
  //     parent.replaceChild(newNode, targetNode)
  //   })
  // }
  //
  // replaceNodeWithText(targetNode, text) {
  //   const newNode = document.createTextNode(text)
  //   const parent = targetNode.parentNode
  //
  //   parent.replaceChild(newNode, targetNode)
  // }
  //
  // insertNode(targetNode, html) {
  //   const newNodes = this.createNodesFromHTML(html)
  //   const parent = targetNode.parentNode
  //   const index = Array.from(parent.children).indexOf(targetNode)
  //
  //   newNodes.forEach(newNode => {
  //     parent.insertBefore(newNode, parent.children[index])
  //   })
  // }
  //
  // insertNodeWithText(targetNode, text) {
  //   const newNode = document.createTextNode(text)
  //   const parent = targetNode.parentNode
  //   const index = Array.from(parent.children).indexOf(targetNode)
  //
  //   parent.insertBefore(newNode, parent.children[index])
  // }
  //
  // deleteNode(targetNode) {
  //   targetNode.parentNode.removeChild(targetNode)
  // }
  //
  // updateAttributes(targetNode, added, deleted) {
  //   const attributes = targetNode.attributes
  //
  //   for (let i = 0; i < attributes.length; i++) {
  //     const attrName = attributes[i].name
  //
  //     if (deleted && deleted.includes(attrName)) {
  //       targetNode.removeAttribute(attrName)
  //     }
  //   }
  //
  //   if (added) {
  //     Object.keys(added).forEach(attrName => {
  //       targetNode.setAttribute(attrName, added[attrName])
  //     })
  //   }
  // }
  //
  // createNodesFromHTML(html) {
  //   const template = document.createElement('template')
  //   template.innerHTML = html
  //   return Array.from(template.content.childNodes)
  // }
}
