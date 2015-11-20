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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151120162008) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "id_maps", force: :cascade do |t|
    t.string   "connec_id",       limit: 255
    t.string   "connec_entity",   limit: 255
    t.integer  "organization_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "external_id",     limit: 255
    t.string   "external_entity", limit: 255
  end

  add_index "id_maps", ["connec_id", "organization_id"], name: "index_id_maps_on_connec_id_and_organization_id"
  add_index "id_maps", ["external_id", "organization_id"], name: "index_id_maps_on_external_id_and_organization_id"
  add_index "id_maps", ["organization_id"], name: "index_id_maps_on_organization_id"

  create_table "organizations", force: :cascade do |t|
    t.string   "provider",              limit: 255
    t.string   "uid",                   limit: 255
    t.string   "name",                  limit: 255
    t.string   "tenant",                limit: 255
    t.string   "oauth_provider",        limit: 255
    t.string   "oauth_uid",             limit: 255
    t.string   "oauth_token",           limit: 255
    t.string   "refresh_token",         limit: 255
    t.string   "instance_url",          limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "synchronized_entities", limit: 255
  end

  add_index "organizations", ["uid"], name: "index_organizations_on_uid"

  create_table "synchronizations", force: :cascade do |t|
    t.string   "provider",        limit: 255
    t.integer  "organization_id"
    t.string   "tenant",          limit: 255
    t.string   "status",          limit: 255
    t.string   "message",         limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "partial",                     default: false
  end

  create_table "user_organization_rels", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_organization_rels", ["organization_id"], name: "index_user_organization_rels_on_organization_id"
  add_index "user_organization_rels", ["user_id"], name: "index_user_organization_rels_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "email",      limit: 255
    t.string   "tenant",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["uid"], name: "index_users_on_uid"

end
