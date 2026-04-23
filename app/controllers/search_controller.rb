class SearchController < ApplicationController
  def books
    query = params[:q].to_s.strip
    books = if query.present?
      Current.user.books.where("title LIKE ? OR author LIKE ?", "%#{query}%", "%#{query}%")
    else
      Current.user.books
    end.order(:title).limit(10)

    render json: books.map { |b|
      { id: b.id, title: b.title, author: b.author, status: b.status, emoji: b.emoji, gradient: b.gradient,
        current_page: b.current_page, pages: b.pages }
    }
  end
end
