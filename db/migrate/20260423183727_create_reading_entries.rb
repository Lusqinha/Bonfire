class CreateReadingEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :reading_entries do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :page
      t.text :body
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
