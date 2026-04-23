class Book < ApplicationRecord
  belongs_to :user
  has_many :reading_entries, dependent: :destroy
  has_many :notes, dependent: :destroy

  enum :status, { want: 0, reading: 1, read: 2 }

  validates :title, :author, presence: true
end
