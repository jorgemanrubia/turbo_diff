export class Selector {
  constructor(selectorString) {
    this.selectorString = selectorString
  }

  get parent() {
    if(this.selectorString.lastIndexOf("/") == -1) {
      return null
    }
    else{
      return new Selector(this.selectorString.slice(0, this.selectorString.lastIndexOf("/")))
    }
  }

  get position() {
    return parseInt(this.selectorString.slice(this.selectorString.lastIndexOf("/") + 1))
  }

  toString() {
    return this.selectorString
  }
}
