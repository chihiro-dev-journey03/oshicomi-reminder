import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.toggleButtons()
  }

  toggle() {
    this.toggleButtons()
  }

  toggleButtons() {
    const enabled = this.checkboxTarget.checked
    this.element.querySelectorAll('button[type="submit"]').forEach(btn => {
      btn.disabled = !enabled
    })
  }
}
