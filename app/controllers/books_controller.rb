class BooksController < ApplicationController
  before_action :set_book, only: %i[show update destroy]

  def show
    entries = @book.reading_entries.order(created_at: :desc).map do |e|
      { id: e.id, page: e.page, body: e.body, created_at: e.created_at.strftime("%-d %b · %H:%M") }
    end
    notes = @book.notes.order(created_at: :desc).map do |n|
      { id: n.id, title: n.title, body: n.body, created_at: n.created_at.strftime("%-d %b") }
    end
    books = Current.user.books.order(:title).map { |b| serialize_book(b) }
    render inertia: "Books/Show", props: {
      book: serialize_book(@book),
      entries:,
      notes:,
      books:
    }
  end

  def create
    book = Current.user.books.build(book_params)
    if book.save
      redirect_to library_path
    else
      redirect_back fallback_location: library_path, alert: book.errors.full_messages.to_sentence
    end
  end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book)
    else
      redirect_back fallback_location: book_path(@book), alert: @book.errors.full_messages.to_sentence
    end
  end

  def destroy
    @book.destroy
    redirect_to library_path
  end

  private

  def set_book
    @book = Current.user.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :publisher, :year, :pages, :current_page, :status, :emoji, :gradient, :cover_url)
  end

  def serialize_book(book)
    {
      id: book.id,
      title: book.title,
      author: book.author,
      publisher: book.publisher,
      year: book.year,
      pages: book.pages,
      current_page: book.current_page,
      status: book.status,
      emoji: book.emoji,
      gradient: book.gradient,
      cover_url: book.cover_url,
      entries_count: book.reading_entries.count,
      notes_count: book.notes.count
    }
  end
end
