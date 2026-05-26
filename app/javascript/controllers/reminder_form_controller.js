import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dialog",
    "recurrenceRadio",
    "intervalInput",
    "dailySection",
    "weeklySection",
    "monthlySection",
    "dayButton",
    "dateSelect",
    "weekdaySelect"
  ]

  // 間隔の上限（日ごと:99, 週ごと:52, ヶ月ごと:12）
  intervalMaxMap = { daily: 99, weekly: 52, monthly: 12 }

  connect() {
    this.switchRecurrence()
    this.switchMonthlyType()
    this.updateDayButtons()
  }

  // 繰り返しタイプの切り替え
  switchRecurrence() {
    const selected = this.recurrenceRadioTargets.find(r => r.checked)?.value || "daily"
    this.dailySectionTarget.classList.toggle("hidden", selected !== "daily")
    this.weeklySectionTarget.classList.toggle("hidden", selected !== "weekly")
    this.monthlySectionTarget.classList.toggle("hidden", selected !== "monthly")

    // 間隔の上限を更新
    const max = this.intervalMaxMap[selected] || 99
    this.intervalInputTarget.max = max
    if (parseInt(this.intervalInputTarget.value) > max) {
      this.intervalInputTarget.value = max
    }
  }

  // 月ごと：日付指定 / 曜日指定の切り替え
  switchMonthlyType() {
    const dateRadio = this.element.querySelector('input[name="reminder[monthly_type]"][value="date"]')
    const isDate = dateRadio?.checked ?? true
    this.dateSelectTarget.disabled = !isDate
    this.weekdaySelectTarget.querySelectorAll("select").forEach(s => s.disabled = isDate)
  }

  // 曜日ボタンの色を更新
  updateDayButtons() {
    this.element.querySelectorAll('input[name="reminder[days_of_week_array][]"]').forEach(cb => {
      const span = cb.nextElementSibling
      if (!span) return
      span.style.backgroundColor = cb.checked ? "#22c55e" : ""
      span.style.color = cb.checked ? "white" : ""
      span.style.borderColor = cb.checked ? "transparent" : ""
    })
  }

  // バックドロップクリックで閉じる
  closeOnBackdrop(event) {
    if (event.target === this.element) this.close()
  }

  // ダイアログを閉じる（turbo-frame をクリア）
  close() {
    const frame = document.getElementById("modal")
    if (frame) frame.innerHTML = ""
  }
}
