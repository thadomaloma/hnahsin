# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_27_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "audit_events", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.bigint "auditable_id", null: false
    t.string "auditable_type", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.string "request_id"
    t.datetime "updated_at", null: false
    t.index ["action", "occurred_at"], name: "index_audit_events_on_action_and_occurred_at"
    t.index ["actor_id"], name: "index_audit_events_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_events_on_auditable"
  end

  create_table "content_items", force: :cascade do |t|
    t.integer "content_type", null: false
    t.datetime "created_at", null: false
    t.string "locale", default: "lus", null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "published_revision_id"
    t.string "stable_id", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["stable_id"], name: "index_content_items_on_stable_id", unique: true
    t.index ["status", "content_type"], name: "index_content_items_on_status_and_content_type"
    t.check_constraint "content_type >= 0 AND content_type <= 6", name: "content_items_type_range"
    t.check_constraint "locale::text = 'lus'::text", name: "content_items_mizo_locale"
    t.check_constraint "status >= 0 AND status <= 4", name: "content_items_status_range"
  end

  create_table "content_pack_entries", force: :cascade do |t|
    t.bigint "content_pack_id", null: false
    t.bigint "content_revision_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_pack_id", "content_revision_id"], name: "index_pack_entries_unique", unique: true
    t.index ["content_pack_id"], name: "index_content_pack_entries_on_content_pack_id"
    t.index ["content_revision_id"], name: "index_content_pack_entries_on_content_revision_id"
  end

  create_table "content_packs", force: :cascade do |t|
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.jsonb "manifest", default: {}, null: false
    t.string "pack_version", null: false
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "published_at"
    t.bigint "rollback_of_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_content_packs_on_created_by_id"
    t.index ["pack_version"], name: "index_content_packs_on_pack_version", unique: true
    t.index ["public_id"], name: "index_content_packs_on_public_id", unique: true
    t.index ["rollback_of_id"], name: "index_content_packs_on_rollback_of_id"
    t.index ["status", "published_at"], name: "index_content_packs_on_status_and_published_at"
    t.check_constraint "checksum::text ~ '^[0-9a-f]{64}$'::text", name: "content_packs_checksum_format"
    t.check_constraint "jsonb_typeof(manifest) = 'object'::text", name: "content_packs_manifest_object"
    t.check_constraint "status >= 0 AND status <= 2", name: "content_packs_status_range"
  end

  create_table "content_revisions", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "author_id", null: false
    t.jsonb "body", default: {}, null: false
    t.string "checksum", null: false
    t.bigint "content_item_id", null: false
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.datetime "published_at"
    t.integer "status", default: 0, null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_content_revisions_on_author_id"
    t.index ["checksum"], name: "index_content_revisions_on_checksum"
    t.index ["content_item_id", "number"], name: "index_content_revisions_on_content_item_id_and_number", unique: true
    t.index ["content_item_id"], name: "index_content_revisions_on_content_item_id"
    t.check_constraint "checksum::text ~ '^[0-9a-f]{64}$'::text", name: "content_revisions_checksum_format"
    t.check_constraint "jsonb_typeof(body) = 'object'::text", name: "content_revisions_body_object"
    t.check_constraint "status >= 0 AND status <= 4", name: "content_revisions_status_range"
  end

  create_table "review_decisions", force: :cascade do |t|
    t.bigint "content_revision_id", null: false
    t.datetime "created_at", null: false
    t.integer "decision", null: false
    t.text "notes"
    t.integer "review_kind", null: false
    t.datetime "reviewed_at", null: false
    t.bigint "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["content_revision_id", "review_kind"], name: "index_review_decisions_once_per_kind", unique: true
    t.index ["content_revision_id"], name: "index_review_decisions_on_content_revision_id"
    t.index ["reviewer_id"], name: "index_review_decisions_on_reviewer_id"
    t.check_constraint "decision >= 0 AND decision <= 1", name: "review_decisions_decision_range"
    t.check_constraint "review_kind >= 0 AND review_kind <= 1", name: "review_decisions_kind_range"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "last_signed_in_at"
    t.string "password_digest", null: false
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.check_constraint "role >= 0 AND role <= 4", name: "users_role_range"
  end

  create_table "word_images", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.string "checksum_sha256", limit: 64, null: false
    t.string "content_type", null: false
    t.datetime "created_at", null: false
    t.binary "data", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id", null: false
    t.index ["checksum_sha256"], name: "index_word_images_on_checksum_sha256", unique: true
    t.index ["uploaded_by_id"], name: "index_word_images_on_uploaded_by_id"
    t.check_constraint "byte_size >= 1 AND byte_size <= 524288", name: "word_images_size_range"
    t.check_constraint "checksum_sha256::text ~ '^[0-9a-f]{64}$'::text", name: "word_images_checksum_format"
    t.check_constraint "content_type::text = ANY (ARRAY['image/png'::character varying, 'image/jpeg'::character varying, 'image/webp'::character varying]::text[])", name: "word_images_content_type"
  end

  add_foreign_key "audit_events", "users", column: "actor_id"
  add_foreign_key "content_items", "content_revisions", column: "published_revision_id"
  add_foreign_key "content_pack_entries", "content_packs"
  add_foreign_key "content_pack_entries", "content_revisions"
  add_foreign_key "content_packs", "content_packs", column: "rollback_of_id"
  add_foreign_key "content_packs", "users", column: "created_by_id"
  add_foreign_key "content_revisions", "content_items"
  add_foreign_key "content_revisions", "users", column: "author_id"
  add_foreign_key "review_decisions", "content_revisions"
  add_foreign_key "review_decisions", "users", column: "reviewer_id"
  add_foreign_key "word_images", "users", column: "uploaded_by_id"
end
