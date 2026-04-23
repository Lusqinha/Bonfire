class ReadingEntriesController < ApplicationController
  before_action :set_book

  def create
    entry = @book.reading_entries.build(entry_params.merge(user: Current.user))
    if entry.save
      @book.update(current_page: entry.page) if entry.page.present?
      redirect_to book_path(@book)
    else
      redirect_back fallback_location: book_path(@book), alert: entry.errors.full_messages.to_sentence
    end
  end

  def update
    entry = Current.user.reading_entries.find(params[:id])
    if entry.update(entry_params)
      redirect_to book_path(@book)
    else
      redirect_back fallback_location: book_path(@book), alert: entry.errors.full_messages.to_sentence
    end
  end

  def destroy
    entry = Current.user.reading_entries.find(params[:id])
    entry.destroy
    redirect_to book_path(@book)
  end

  private

  def set_book
    @book = Current.user.books.find(params[:book_id])
  end

  def entry_params
    params.require(:reading_entry).permit(:page, :body)
  end
end
