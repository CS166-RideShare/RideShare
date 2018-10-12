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

ActiveRecord::Schema.define(version: 2018_10_11_033849) do

  create_table "rides", force: :cascade do |t|
    t.integer "rider_id"
    t.integer "driver_id"
    t.time "post_time"
    t.string "destination"
    t.time "scheduled_time"
    t.integer "canceled_by"
    t.boolean "finished"
    t.integer "rider_review_level"
    t.string "rider_review"
    t.integer "driver_review_level"
    t.integer "driver_review"
    t.boolean "review_handled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "is_driver"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
