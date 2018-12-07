# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_12_05_180847) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "ride_id"
    t.integer "rider_review_level"
    t.text "rider_review"
    t.integer "driver_review_level"
    t.text "driver_review"
    t.boolean "review_handled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rides", force: :cascade do |t|
    t.integer "rider_id"
    t.integer "driver_id"
    t.string "starting_id"
    t.string "destination_id"
    t.string "starting_address"
    t.string "destination_address"
    t.integer "canceled_by"
    t.boolean "finished", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "starting_lat"
    t.string "starting_lng"
    t.string "destination_lat"
    t.string "destination_lng"
    t.datetime "pickup_start"
    t.datetime "pickup_end"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "license_number"
    t.boolean "is_driver"
    t.integer "gender"
    t.text "introduction"
    t.string "vehicle_make"
    t.string "vehicle_model"
    t.string "vehicle_plate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.string "phone_number"
    t.string "emergency_contact"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
