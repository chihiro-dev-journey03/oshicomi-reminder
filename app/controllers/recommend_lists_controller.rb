class RecommendListsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_recommend_list, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def new
    @recommend_list = current_user.recommend_lists.build(status: :draft)
    build_items_from_reminders
  end

  def create
    @recommend_list = current_user.recommend_lists.build(recommend_list_params)

    if @recommend_list.save
      redirect_to @recommend_list, notice: "推しコミリストを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    unless @recommend_list.published? || (user_signed_in? && @recommend_list.user == current_user)
      redirect_to root_path, alert: "このリストは公開されていません"
    end
  end

  def edit
    @available_books = available_books_for_addition
  end

  def update
    if @recommend_list.update(recommend_list_params)
      add_books_from_params
      redirect_to @recommend_list, notice: "推しコミリストを更新しました"
    else
      @available_books = available_books_for_addition
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recommend_list.destroy
    redirect_to root_path, notice: "推しコミリストを削除しました"
  end

  private

  def set_recommend_list
    @recommend_list = RecommendList.includes(recommend_list_items: :book).find(params[:id])
  end

  def authorize_owner!
    redirect_to root_path, alert: "権限がありません" unless @recommend_list.user == current_user
  end

  def build_items_from_reminders
    current_user.reminders.includes(:book).map(&:book).compact.uniq(&:id).each do |book|
      book.enrich_from_rakuten!
      @recommend_list.recommend_list_items.build(book: book)
    end
  end

  def available_books_for_addition
    existing_book_ids = @recommend_list.recommend_list_items.map(&:book_id)
    current_user.reminders.includes(:book).map(&:book).compact.uniq(&:id).reject do |book|
      existing_book_ids.include?(book.id)
    end
  end

  def add_books_from_params
    return if params[:add_book_ids].blank?

    params[:add_book_ids].each do |book_id|
      comment = params.dig(:add_book_comments, book_id)
      @recommend_list.recommend_list_items.find_or_create_by(book_id: book_id) do |item|
        item.comment = comment
      end
    end
  end

  def recommend_list_params
    params.require(:recommend_list).permit(
      :title,
      :description,
      :status,
      recommend_list_items_attributes: [ :id, :book_id, :comment, :_destroy ]
    )
  end
end
