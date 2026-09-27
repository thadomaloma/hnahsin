class CreateEditorialCore < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 1
      t.boolean :active, null: false, default: true
      t.datetime :last_signed_in_at
      t.timestamps
    end
    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_check_constraint :users, "role BETWEEN 0 AND 4", name: "users_role_range"

    create_table :content_items do |t|
      t.string :stable_id, null: false
      t.integer :content_type, null: false
      t.string :locale, null: false, default: "lus"
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.bigint :published_revision_id
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    add_index :content_items, :stable_id, unique: true
    add_index :content_items, %i[status content_type]
    add_check_constraint :content_items, "locale = 'lus'", name: "content_items_mizo_locale"
    add_check_constraint :content_items, "content_type BETWEEN 0 AND 4", name: "content_items_type_range"
    add_check_constraint :content_items, "status BETWEEN 0 AND 4", name: "content_items_status_range"

    create_table :content_revisions do |t|
      t.references :content_item, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.integer :number, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :body, null: false, default: {}
      t.string :checksum, null: false
      t.datetime :submitted_at
      t.datetime :approved_at
      t.datetime :published_at
      t.timestamps
    end
    add_index :content_revisions, %i[content_item_id number], unique: true
    add_index :content_revisions, :checksum
    add_check_constraint :content_revisions, "status BETWEEN 0 AND 4", name: "content_revisions_status_range"
    add_check_constraint :content_revisions, "checksum ~ '^[0-9a-f]{64}$'", name: "content_revisions_checksum_format"
    add_check_constraint :content_revisions, "jsonb_typeof(body) = 'object'", name: "content_revisions_body_object"

    add_foreign_key :content_items, :content_revisions, column: :published_revision_id

    create_table :review_decisions do |t|
      t.references :content_revision, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.integer :review_kind, null: false
      t.integer :decision, null: false
      t.text :notes
      t.datetime :reviewed_at, null: false
      t.timestamps
    end
    add_index :review_decisions, %i[content_revision_id review_kind], unique: true,
      name: "index_review_decisions_once_per_kind"
    add_check_constraint :review_decisions, "review_kind BETWEEN 0 AND 1", name: "review_decisions_kind_range"
    add_check_constraint :review_decisions, "decision BETWEEN 0 AND 1", name: "review_decisions_decision_range"

    create_table :content_packs do |t|
      t.uuid :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :pack_version, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :manifest, null: false, default: {}
      t.string :checksum, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :rollback_of, foreign_key: { to_table: :content_packs }
      t.datetime :published_at
      t.timestamps
    end
    add_index :content_packs, :public_id, unique: true
    add_index :content_packs, :pack_version, unique: true
    add_index :content_packs, %i[status published_at]
    add_check_constraint :content_packs, "status BETWEEN 0 AND 2", name: "content_packs_status_range"
    add_check_constraint :content_packs, "checksum ~ '^[0-9a-f]{64}$'", name: "content_packs_checksum_format"
    add_check_constraint :content_packs, "jsonb_typeof(manifest) = 'object'", name: "content_packs_manifest_object"

    create_table :content_pack_entries do |t|
      t.references :content_pack, null: false, foreign_key: true
      t.references :content_revision, null: false, foreign_key: true
      t.timestamps
    end
    add_index :content_pack_entries, %i[content_pack_id content_revision_id],
      unique: true, name: "index_pack_entries_unique"

    create_table :audit_events do |t|
      t.references :actor, foreign_key: { to_table: :users }
      t.references :auditable, polymorphic: true, null: false
      t.string :action, null: false
      t.string :request_id
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :audit_events, %i[action occurred_at]
  end
end
