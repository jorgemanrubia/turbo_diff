 class DiffChanges {
  constructor(fromNode, toNode, changes) {
    this.fromNode = fromNode;
    this.toNode = toNode;
    this.changes = changes;
  }

  apply() {
    this.changes.forEach(change => {
      const { type, selector, html, text, added, deleted } = change;
      const targetNode = this.getNodeBySelector(selector);

      if (type === 'replace') {
        if (html) {
          this.replaceNode(targetNode, html);
        } else if (text) {
          this.replaceNodeWithText(targetNode, text);
        }
      } else if (type === 'insert') {
        if (html) {
          this.insertNode(targetNode, html);
        } else if (text) {
          this.insertNodeWithText(targetNode, text);
        }
      } else if (type === 'delete') {
        this.deleteNode(targetNode);
      } else if (type === 'attributes') {
        this.updateAttributes(targetNode, added, deleted);
      }
    });

    return this.fromNode;
  }

  // Private

  getNodeBySelector(selector) {
    const parts = selector.split('/').map(Number);
    let currentNode = this.fromNode;

    for (let i = 0; i < parts.length; i++) {
      currentNode = currentNode.children[parts[i]];
    }

    return currentNode;
  }

  replaceNode(targetNode, html) {
    const newNodes = this.createNodesFromHTML(html);
    const parent = targetNode.parentNode;

    newNodes.forEach(newNode => {
      parent.replaceChild(newNode, targetNode);
    });
  }

  replaceNodeWithText(targetNode, text) {
    const newNode = document.createTextNode(text);
    const parent = targetNode.parentNode;

    parent.replaceChild(newNode, targetNode);
  }

  insertNode(targetNode, html) {
    const newNodes = this.createNodesFromHTML(html);
    const parent = targetNode.parentNode;
    const index = Array.from(parent.children).indexOf(targetNode);

    newNodes.forEach(newNode => {
      parent.insertBefore(newNode, parent.children[index]);
    });
  }

  insertNodeWithText(targetNode, text) {
    const newNode = document.createTextNode(text);
    const parent = targetNode.parentNode;
    const index = Array.from(parent.children).indexOf(targetNode);

    parent.insertBefore(newNode, parent.children[index]);
  }

  deleteNode(targetNode) {
    targetNode.parentNode.removeChild(targetNode);
  }

  updateAttributes(targetNode, added, deleted) {
    const attributes = targetNode.attributes;

    for (let i = 0; i < attributes.length; i++) {
      const attrName = attributes[i].name;

      if (deleted && deleted.includes(attrName)) {
        targetNode.removeAttribute(attrName);
      }
    }

    if (added) {
      Object.keys(added).forEach(attrName => {
        targetNode.setAttribute(attrName, added[attrName]);
      });
    }
  }
}
