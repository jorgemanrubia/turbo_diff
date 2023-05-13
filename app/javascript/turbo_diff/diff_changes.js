export class DiffChanges {
  constructor(fromNode, changes) {
    this.fromNode = fromNode
    this.changes = changes
  }

  apply() {
    this.changes.forEach(change => {
      const { type, selector, html, text, added, deleted } = change
      const targetNode = this.getNodeBySelector(selector)

      if (type === 'replace') {
        this.replace(html, targetNode, text);
      } else if (type === 'insert') {
        this.insert(html, targetNode, text);
      } else if (type === 'delete') {
        this.deleteNode(targetNode)
      } else if (type === 'attributes') {
        this.updateAttributes(targetNode, added, deleted)
      }
    })

    return this.fromNode
  }

  replace(html, targetNode, text) {
    if (html) {
      this.replaceNode(targetNode, html)
    } else if (text) {
      this.replaceNodeWithText(targetNode, text)
    }
  }

  insert(html, targetNode, text) {
    if (html) {
      this.insertNode(targetNode, html)
    } else if (text) {
      this.insertNodeWithText(targetNode, text)
    }
  }

  // Simple unoptimized implementation
  getNodeBySelector(selector) {
    const parts = selector.split('/').map(Number)
    if(parts.shift() != 0)
      throw "Only documents with a single root supported"

    let currentNode = this.fromNode

    for (let i = 0; i < parts.length; i++) {
      const filteredNodes = Array.from(currentNode.childNodes).filter(node => {
        return (node.nodeType === Node.TEXT_NODE && node.textContent.trim()) || node.nodeType === Node.ELEMENT_NODE
      })

      currentNode = filteredNodes[parts[i]]
    }

    return currentNode
  }

  replaceNode(targetNode, html) {
    const newNodes = this.createNodesFromHTML(html)
    const parent = targetNode.parentNode

    newNodes.forEach(newNode => {
      parent.replaceChild(newNode, targetNode)
    })
  }

  replaceNodeWithText(targetNode, text) {
    const newNode = document.createTextNode(text)
    const parent = targetNode.parentNode

    parent.replaceChild(newNode, targetNode)
  }

  insertNode(targetNode, html) {
    const newNodes = this.createNodesFromHTML(html)
    const parent = targetNode.parentNode
    const index = Array.from(parent.children).indexOf(targetNode)

    newNodes.forEach(newNode => {
      parent.insertBefore(newNode, parent.children[index])
    })
  }

  insertNodeWithText(targetNode, text) {
    const newNode = document.createTextNode(text)
    const parent = targetNode.parentNode
    const index = Array.from(parent.children).indexOf(targetNode)

    parent.insertBefore(newNode, parent.children[index])
  }

  deleteNode(targetNode) {
    targetNode.parentNode.removeChild(targetNode)
  }

  updateAttributes(targetNode, added, deleted) {
    const attributes = targetNode.attributes

    for (let i = 0; i < attributes.length; i++) {
      const attrName = attributes[i].name

      if (deleted && deleted.includes(attrName)) {
        targetNode.removeAttribute(attrName)
      }
    }

    if (added) {
      Object.keys(added).forEach(attrName => {
        targetNode.setAttribute(attrName, added[attrName])
      })
    }
  }

  createNodesFromHTML(html) {
    const template = document.createElement('template')
    template.innerHTML = html
    return Array.from(template.content.childNodes)
  }
}
