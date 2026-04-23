class LibraryController < ApplicationController
  def index
    books = Current.user.books.order(:title).map { |b| serialize_book(b) }
    render inertia: "Library/Index", props: { books: }
  end

  private

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
