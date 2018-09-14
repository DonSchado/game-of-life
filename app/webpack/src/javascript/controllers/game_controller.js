import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'cell', 'state', 'drawBtn', 'share' ]

  initialize() {
    const drawMode = false
  }

  connect() {
    Turbolinks.clearCache() // avoids glitches after page reload
  }

  toggleCell(event) {
    const cell = event.target
    cell.dataset.state = parseInt(cell.dataset.state) ? 0 : 1
  }

  generation() {
    this.drawMode = false
    this.stateTarget.value = this.cellTargets
      .map(cell => cell.dataset.state)
      .join('')
      .replace(/0+$/, '')
  }

  enableDraw(event) {
    if (event.keyCode === 68) { // d
      this.toggleDrawMode()
    }
  }

  draw(event) {
    if (this.drawMode) {
      this.toggleCell(event)
    }
  }

  toggleDrawMode() {
    const btn = this.drawBtnTarget
    this.drawMode = btn.classList.toggle(btn.dataset.activeClass)
  }

  copy(event) {
    this.generation()
    this.shareTarget.href = this.stateTarget.value
  }
}
