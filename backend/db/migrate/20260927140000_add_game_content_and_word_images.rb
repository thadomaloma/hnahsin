# Lets Editorial Studio manage every piece of game content: Tawng Upa
# questions and per-game Mizo copy become content types, and Picture Match
# pictures are uploaded into PostgreSQL (no object storage needed).
class AddGameContentAndWordImages < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :content_items, name: "content_items_type_range"
    add_check_constraint :content_items, "content_type >= 0 AND content_type <= 6", name: "content_items_type_range"

    create_table :word_images do |t|
      t.string :checksum_sha256, null: false, limit: 64
      t.string :content_type, null: false
      t.integer :byte_size, null: false
      t.binary :data, null: false
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :word_images, :checksum_sha256, unique: true
    add_check_constraint :word_images, "byte_size >= 1 AND byte_size <= 524288", name: "word_images_size_range"
    add_check_constraint :word_images, "checksum_sha256 ~ '^[0-9a-f]{64}$'", name: "word_images_checksum_format"
    add_check_constraint :word_images, "content_type IN ('image/png', 'image/jpeg', 'image/webp')",
      name: "word_images_content_type"
  end
end
