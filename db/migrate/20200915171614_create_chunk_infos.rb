class CreateChunkInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :chunk_infos do |t|
      t.integer :chunk_number, null: false
      t.integer :last_line_number, null: false
      t.belongs_to :file_detail, null: false

      t.timestamps
    end
  end
end
