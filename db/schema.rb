# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140602012201) do

  create_table "contacts", :force => true do |t|
    t.string   "user_inst"
    t.string   "partner_inst"
    t.integer  "encounter_id"
    t.boolean  "barriers"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "encounters", :force => true do |t|
    t.boolean  "fluid"
    t.text     "notes"
    t.integer  "self_risk"
    t.date     "took_place"
    t.integer  "user_id"
    t.integer  "partner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "infections", :force => true do |t|
    t.string   "disease"
    t.boolean  "positive"
    t.integer  "sti_test_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "partnerships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "partner_id"
    t.integer  "familiarity"
    t.integer  "exclusivity"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password_digest"
    t.string   "pronoun"
    t.string   "anus_name"
    t.string   "genital_name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "sti_tests", :force => true do |t|
    t.date     "date_taken"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
