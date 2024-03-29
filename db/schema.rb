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

ActiveRecord::Schema[7.0].define(version: 2023_11_11_014225) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_responses", force: :cascade do |t|
    t.text "content"
    t.text "original_text_id"
    t.bigint "conversation_id"
    t.bigint "chat_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "prompt_id"
    t.index ["chat_entry_id"], name: "index_ai_responses_on_chat_entry_id"
    t.index ["conversation_id"], name: "index_ai_responses_on_conversation_id"
    t.index ["prompt_id"], name: "index_ai_responses_on_prompt_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "title", comment: "category title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_categories_on_title", unique: true
  end

  create_table "chat_entries", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.text "content"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ai_response_id"
    t.index ["ai_response_id"], name: "index_chat_entries_on_ai_response_id"
    t.index ["conversation_id"], name: "index_chat_entries_on_conversation_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title", null: false
    t.integer "price_type"
    t.text "description"
    t.decimal "price_init", precision: 10, scale: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_products_on_title", unique: true
  end

  create_table "prompts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

  add_foreign_key "ai_responses", "chat_entries"
  add_foreign_key "ai_responses", "conversations"
  add_foreign_key "chat_entries", "ai_responses"
  add_foreign_key "chat_entries", "conversations"
  add_foreign_key "conversations", "users"
end
