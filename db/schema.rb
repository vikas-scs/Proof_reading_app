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

ActiveRecord::Schema.define(version: 2021_06_03_033849) do

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "role"
    t.float "wallet", default: 0.0
    t.string "status", default: "available"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "costs", force: :cascade do |t|
    t.float "word_cost"
    t.float "admin_commission"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "fine_amount"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "coupon_code"
    t.float "amount"
    t.float "percentage"
    t.integer "coupon_usage_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cupons", force: :cascade do |t|
    t.string "coupon_name"
    t.float "amount"
    t.float "percentage"
    t.integer "usage_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "expired_date"
  end

  create_table "cupons_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "cupon_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invites", force: :cascade do |t|
    t.integer "post_id"
    t.integer "host_id"
    t.integer "reciever_id"
    t.string "invite_status"
    t.string "read_status"
    t.integer "error_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "time_taken"
  end

  create_table "posts", force: :cascade do |t|
    t.string "post"
    t.string "status"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cupon_id"
    t.integer "ref_id"
    t.float "coupon_benifit"
    t.date "cupon_date"
  end

  create_table "statements", force: :cascade do |t|
    t.string "statement_type"
    t.string "action"
    t.integer "user_id"
    t.integer "post_id"
    t.integer "admin_id"
    t.string "debit_from"
    t.string "credit_to"
    t.float "amount"
    t.float "debitor_balance"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "invite_id"
    t.string "ref_id"
    t.float "word_cost"
    t.float "admin_commission"
  end

  create_table "user_wallets", force: :cascade do |t|
    t.integer "user_id"
    t.float "balance"
    t.float "lock_balance"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.integer "mobile"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
