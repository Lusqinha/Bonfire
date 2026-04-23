class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :publisher
      t.integer :year
      t.integer :pages
      t.integer :current_page
      t.integer :status
      t.string :emoji
      t.string :gradient
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
