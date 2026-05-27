class BooksController < ApplicationController
  before_action :authenticate_user!

  def search
    keyword = params[:keyword].to_s.strip

    if keyword.blank?
      return render json: { error: "キーワードを入力してください" }, status: :unprocessable_entity
    end

    book_data_list = RakutenBooksService.search(keyword)

    books = book_data_list.map do |book_data|
      Book.find_or_create_from_rakuten(book_data)
    end

    render json: books.map { |book|
      {
        id: book.id,
        title: book.title,
        author: book.author,
        image_url: book.image_url
      }
    }
  end
end
