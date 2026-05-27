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
                class="w-full flex items-center gap-3 px-3 py-2 hover:bg-green-50 transition text-left"
                data-action="click->book-search#select"
                data-title="${this.escapeAttr(book.title)}">
          ${book.image_url
            ? `<img src="${this.escapeAttr(book.image_url)}" class="w-10 h-14 object-cover rounded flex-shrink-0" />`
            : `<div class="w-10 h-14 bg-gray-100 rounded flex-shrink-0 flex items-center justify-center">
                 <svg class="w-5 h-5 text-gray-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                   <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                 </svg>
               </div>`
          }
          <div class="min-w-0">
            <p class="text-sm font-medium text-gray-800 line-clamp-2">${this.escapeHtml(book.title)}</p>
            ${book.author ? `<p class="text-xs text-gray-500 truncate mt-0.5">${this.escapeHtml(book.author)}</p>` : ""}
          </div>
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
