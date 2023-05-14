export function filterElementAndTextNodes(nodes) {
  return Array.from(nodes).filter(node => {
    return (node.nodeType === Node.TEXT_NODE && node.textContent.trim()) || node.nodeType === Node.ELEMENT_NODE
  })
}
