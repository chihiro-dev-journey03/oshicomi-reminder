require 'rails_helper'

RSpec.describe "Reminders", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book, title: "進撃の巨人") }

  before { sign_in user }

  describe "GET /reminders" do
    it "200を返す" do
      get reminders_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /reminders/new" do
    it "200を返す" do
      get new_reminder_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /reminders" do
    let(:valid_params) do
      {
        reminder: {
          book_title:          "進撃の巨人",
          recurrence_type:     "daily",
          recurrence_interval: 1,
          time_hour:           9,
          time_minute:         0,
          monthly_type:        "date",
          day_of_month:        1
        }
      }
    end

    context "正常系" do
      before do
        allow(Book).to receive(:find_or_create_by_base_title).and_return(book)
      end

      it "リマインダーを作成してリダイレクトする" do
        expect {
          post reminders_path, params: valid_params
        }.to change(Reminder, :count).by(1)
        expect(response).to redirect_to(reminders_path)
      end
    end

    context "book_titleが空の場合" do
      it "422を返す" do
        post reminders_path, params: {
          reminder: valid_params[:reminder].merge(book_title: "")
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /reminders/:id/edit" do
    context "自分のリマインダーの場合" do
      let!(:reminder) { create(:reminder, user: user, book: book) }

      it "200を返す" do
        get edit_reminder_path(reminder)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他人のリマインダーの場合" do
      let(:other_user) { create(:user) }
      let!(:reminder)  { create(:reminder, user: other_user, book: book) }

      it "404を返す" do
        get edit_reminder_path(reminder)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /reminders/:id" do
    let!(:reminder) { create(:reminder, user: user, book: book) }

    context "正常系" do
      before do
        allow(Book).to receive(:find_or_create_by_base_title).and_return(book)
      end

      it "リマインダーを更新してリダイレクトする" do
        patch reminder_path(reminder), params: {
          reminder: {
            book_title:          "進撃の巨人",
            recurrence_type:     "daily",
            recurrence_interval: 2,
            time_hour:           10,
            time_minute:         0,
            monthly_type:        "date",
            day_of_month:        1
          }
        }
        expect(response).to redirect_to(reminders_path)
        expect(reminder.reload.time_hour).to eq(10)
      end
    end
  end

  describe "DELETE /reminders/:id" do
    let!(:reminder) { create(:reminder, user: user, book: book) }

    it "リマインダーを削除してリダイレクトする" do
      expect {
        delete reminder_path(reminder)
      }.to change(Reminder, :count).by(-1)
      expect(response).to redirect_to(reminders_path)
    end
  end
end
