class CreateFileDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :file_details do |t|
      t.integer :size
      t.integer :lines_number
      t.string :name, null: false

      t.timestamps
    end
  end
end
