class RecommendListsController < ApplicationController
  before_action :authenticate_user!

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
    @recommend_list = RecommendList.includes(recommend_list_items: :book).find(params[:id])
  end

  private

  def build_items_from_reminders
    current_user.reminders.includes(:book).map(&:book).compact.uniq(&:id).each do |book|
      book.enrich_from_rakuten!
      @recommend_list.recommend_list_items.build(book: book)
    end
  end

  def recommend_list_params
    params.require(:recommend_list).permit(
      :title,
      :description,
      recommend_list_items_attributes: [ :book_id, :comment ]
    )
  end
end
