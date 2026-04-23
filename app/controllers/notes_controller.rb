class NotesController < ApplicationController
  before_action :set_book

  def create
    note = @book.notes.build(note_params.merge(user: Current.user))
    if note.save
      redirect_to book_path(@book)
    else
      redirect_back fallback_location: book_path(@book), alert: note.errors.full_messages.to_sentence
    end
  end

  def update
    note = Current.user.notes.find(params[:id])
    if note.update(note_params)
      redirect_to book_path(@book)
    else
      redirect_back fallback_location: book_path(@book), alert: note.errors.full_messages.to_sentence
    end
  end

  def destroy
    note = Current.user.notes.find(params[:id])
    note.destroy
    redirect_to book_path(@book)
  end

  private

  def set_book
    @book = Current.user.books.find(params[:book_id])
  end

  def note_params
    params.require(:note).permit(:title, :body)
  end
end
