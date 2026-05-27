import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loading"]

  connect() {
    this.debounceTimer = null
    this._boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this._boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._boundClickOutside)
    clearTimeout(this.debounceTimer)
  }

  search() {
    clearTimeout(this.debounceTimer)
    const keyword = this.inputTarget.value.trim()

    if (keyword.length < 2) {
      this.hideResults()
      return
    }

    this.debounceTimer = setTimeout(() => this.fetchBooks(keyword), 400)
  }

  async fetchBooks(keyword) {
    this.showLoading()

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(`/books/search?keyword=${encodeURIComponent(keyword)}`, {
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })

      if (!response.ok) throw new Error("Search failed")

      const books = await response.json()
      this.showResults(books)
    } catch {
      this.hideResults()
    } finally {
      this.hideLoading()
    }
  }

  showResults(books) {
    if (books.length === 0) {
      this.resultsTarget.innerHTML =
        `<div class="px-4 py-3 text-sm text-gray-500">見つかりませんでした</div>`
    } else {
      this.resultsTarget.innerHTML = books.map(book => `
        <button type="button"
                class="w-full px-4 py-2.5 hover:bg-green-50 transition text-left text-sm text-gray-800 truncate"
                data-action="click->book-search#select"
                data-title="${this.escapeAttr(book.title)}">
          ${this.escapeHtml(book.title)}
        </button>
      `).join("")
    }
    this.resultsTarget.classList.remove("hidden")
  }

  select(event) {
    const title = event.currentTarget.dataset.title
    this.inputTarget.value = title
    this.hideResults()
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.resultsTarget.innerHTML = ""
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }

  escapeAttr(str) {
    return String(str).replace(/"/g, "&quot;").replace(/'/g, "&#39;")
  }
}
