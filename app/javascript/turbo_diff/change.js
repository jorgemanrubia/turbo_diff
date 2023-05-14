import { Selector } from "turbo_diff/selector"

export class Change {
  constructor(change) {
    this.change = change
  }

  apply() {
    throw "Not implemented"
  }

  // Protected

  log(...message) {
    console.log(...message)
  }

  get selector() {
    return new Selector(this.change.selector)
  }
}
