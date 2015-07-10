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

ActiveRecord::Schema.define(:version => 20150310120619) do

  create_table "admin_commissions", :force => true do |t|
    t.float    "commission_amount"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "admins_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins_store_categories", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archived_bids", :force => true do |t|
    t.integer  "auction_id"
    t.integer  "vendor_id"
    t.decimal  "max_value",  :precision => 8, :scale => 2
    t.datetime "bid_at"
  end

  create_table "auction_addresses", :force => true do |t|
    t.integer  "auction_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auction_images", :force => true do |t|
    t.integer  "user_id"
    t.integer  "auction_id"
    t.datetime "image_updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auction_outcome_vendors", :force => true do |t|
    t.integer  "auction_outcome_id"
    t.integer  "vendor_id"
    t.boolean  "accepted"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_accepted"
  end

  create_table "auction_outcomes", :force => true do |t|
    t.integer  "auction_id"
    t.boolean  "purchase_made"
    t.datetime "confirmed_at"
    t.datetime "first_reminder_sent_at"
    t.datetime "second_reminder_sent_at"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auctions", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "service_category_id"
    t.string   "status"
    t.boolean  "product_auction",                                        :default => false
    t.integer  "duration"
    t.string   "budget"
    t.integer  "min_vendors"
    t.integer  "max_vendors"
    t.datetime "desired_time"
    t.datetime "contact_time"
    t.datetime "contact_time_to"
    t.string   "contact_time_of_day"
    t.string   "vendor_restriction"
    t.text     "extra_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "desired_time_to"
    t.string   "contact_way"
    t.integer  "product_category_id"
    t.string   "delivery_method"
    t.integer  "score"
    t.datetime "end_time"
    t.decimal  "user_earnings",            :precision => 8, :scale => 2
    t.integer  "budget_min"
    t.integer  "budget_max"
    t.integer  "claimed_score"
    t.boolean  "from_mobile"
    t.boolean  "loading_affiliate_offers"
  end

  create_table "auctions_vendors", :force => true do |t|
    t.integer  "auction_id"
    t.integer  "vendor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "avant_advertiser_category_mappings", :force => true do |t|
    t.integer  "avant_advertiser_id"
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "preferred"
  end

  create_table "avant_advertisers", :force => true do |t|
    t.string   "name"
    t.string   "advertiser_id"
    t.string   "advertiser_url"
    t.decimal  "commission_percent", :precision => 8, :scale => 2
    t.decimal  "commission_dollars", :precision => 8, :scale => 2
    t.text     "params"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.boolean  "inactive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mobile_enabled"
  end

  add_index "avant_advertisers", ["advertiser_id"], :name => "index_avant_advertisers_on_advertiser_id", :unique => true

  create_table "avant_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "avant_offer_id"
    t.decimal  "price",               :precision => 8, :scale => 2
    t.decimal  "commission_amount",   :precision => 8, :scale => 2
    t.integer  "auction_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "resulting_balance",   :precision => 8, :scale => 2
  end

  create_table "avant_coupons", :force => true do |t|
    t.string   "advertiser_name"
    t.string   "advertiser_id"
    t.string   "ad_id"
    t.string   "ad_url"
    t.string   "header"
    t.string   "code"
    t.text     "description"
    t.date     "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manually_uploaded"
  end

  add_index "avant_coupons", ["ad_id"], :name => "index_avant_coupons_on_ad_id", :unique => true

  create_table "avant_offers", :force => true do |t|
    t.string   "name"
    t.integer  "auction_id"
    t.string   "advertiser_id"
    t.string   "advertiser_name"
    t.decimal  "price",              :precision => 8, :scale => 2
    t.string   "buy_url"
    t.decimal  "commission_percent", :precision => 8, :scale => 2
    t.decimal  "commission_dollars", :precision => 8, :scale => 2
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bids", :force => true do |t|
    t.integer  "auction_id"
    t.integer  "vendor_id"
    t.boolean  "is_winning",                                  :default => false
    t.decimal  "max_value",     :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_value"
    t.integer  "campaign_id"
    t.integer  "offer_id"
  end

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.integer  "vendor_id"
    t.boolean  "product_campaign",                                             :default => false
    t.string   "score"
    t.decimal  "max_bid",                        :precision => 8, :scale => 2
    t.decimal  "min_bid",                        :precision => 8, :scale => 2
    t.decimal  "fixed_bid",                      :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.decimal  "budget",                         :precision => 8, :scale => 2
    t.integer  "score_min"
    t.integer  "score_max"
    t.integer  "offer_id"
    t.datetime "stop_at"
    t.decimal  "total_spent",                    :precision => 8, :scale => 2
    t.datetime "low_funds_notification_sent_at"
    t.string   "zip_code"
    t.integer  "zip_code_miles_radius"
  end

  create_table "campaigns_product_categories", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns_service_categories", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "service_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns_zip_codes", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "zip_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cj_advertiser_category_mappings", :force => true do |t|
    t.integer  "cj_advertiser_id"
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "preferred"
  end

  create_table "cj_advertisers", :force => true do |t|
    t.string   "name"
    t.string   "advertiser_id"
    t.string   "sample_link_id"
    t.decimal  "commission_percent",     :precision => 8, :scale => 2
    t.decimal  "commission_dollars",     :precision => 8, :scale => 2
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inactive"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.float    "max_commission_percent"
    t.decimal  "max_commission_dollars", :precision => 8, :scale => 2
    t.boolean  "mobile_enabled"
  end

  add_index "cj_advertisers", ["advertiser_id"], :name => "index_cj_advertisers_on_advertiser_id", :unique => true

  create_table "cj_advertisers_product_categories", :force => true do |t|
    t.integer  "cj_advertiser_id"
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cj_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "cj_offer_id"
    t.decimal  "price",               :precision => 8, :scale => 2
    t.decimal  "commission_amount",   :precision => 8, :scale => 2
    t.integer  "auction_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "resulting_balance",   :precision => 8, :scale => 2
  end

  create_table "cj_coupons", :force => true do |t|
    t.string   "advertiser_name"
    t.string   "advertiser_id"
    t.string   "ad_id"
    t.string   "ad_url"
    t.string   "header"
    t.string   "code"
    t.text     "description"
    t.date     "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manually_uploaded"
  end

  add_index "cj_coupons", ["ad_id"], :name => "index_cj_coupons_on_ad_id", :unique => true
  add_index "cj_coupons", ["advertiser_id", "code"], :name => "index_cj_coupons_on_advertiser_id_and_code", :unique => true

  create_table "cj_offers", :force => true do |t|
    t.string   "name"
    t.integer  "auction_id"
    t.string   "ad_id"
    t.string   "advertiser_id"
    t.string   "advertiser_name"
    t.decimal  "price",               :precision => 8, :scale => 2
    t.string   "buy_url"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "expected_commission", :precision => 8, :scale => 2
    t.boolean  "commission_payed"
    t.decimal  "commission_value",    :precision => 8, :scale => 2
  end

  create_table "custom_advertisers", :force => true do |t|
    t.string   "name"
    t.string   "advertiser_url"
    t.boolean  "inactive"
    t.boolean  "mobile_enabled",                                       :default => false
    t.float    "max_commission_percent"
    t.decimal  "max_commission_dollars", :precision => 8, :scale => 2
    t.string   "logo_file_name"
    t.datetime "logo_updated_at"
    t.integer  "logo_file_size"
    t.string   "logo_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "email_contents", :force => true do |t|
    t.string   "name"
    t.text     "hello_sub_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_mail",      :default => true
  end

  create_table "favorite_advertisers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "cj_advertiser_id"
    t.integer  "avant_advertiser_id"
    t.integer  "linkshare_advertiser_id"
    t.integer  "pj_advertiser_id"
    t.integer  "ir_advertiser_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_advertisers", ["avant_advertiser_id"], :name => "index_favorite_advertisers_on_avant_advertiser_id"
  add_index "favorite_advertisers", ["cj_advertiser_id"], :name => "index_favorite_advertisers_on_cj_advertiser_id"
  add_index "favorite_advertisers", ["linkshare_advertiser_id"], :name => "index_favorite_advertisers_on_linkshare_advertiser_id"
  add_index "favorite_advertisers", ["user_id"], :name => "index_favorite_advertisers_on_user_id"

  create_table "funds_refunds", :force => true do |t|
    t.integer  "vendor_id"
    t.decimal  "requested_amount",  :precision => 8, :scale => 2
    t.decimal  "refunded_amount",   :precision => 8, :scale => 2
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
  end

  create_table "funds_refunds_funds_transfers", :force => true do |t|
    t.integer "funds_refund_id"
    t.integer "funds_transfer_id"
  end

  create_table "funds_transfer_transactions", :force => true do |t|
    t.integer  "funds_transfer_id"
    t.string   "action"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funds_transfers", :force => true do |t|
    t.integer  "vendor_id"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.string   "status"
    t.string   "paypal_token"
    t.string   "paypal_payer_id"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "refunded_amount",   :precision => 8, :scale => 2
    t.boolean  "use_credit_card"
    t.string   "card_type"
    t.string   "card_first_name"
    t.string   "card_last_name"
    t.string   "card_last_digits"
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
  end

  create_table "funds_withdrawal_notifications", :force => true do |t|
    t.integer  "funds_withdrawal_id"
    t.string   "status"
    t.string   "receiver_email"
    t.string   "transaction_id"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funds_withdrawals", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.string   "paypal_email"
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
  end

  create_table "hp_advertiser_images", :force => true do |t|
    t.string   "hp_image_file_name"
    t.datetime "hp_image_updated_at"
    t.integer  "hp_image_file_size"
    t.string   "hp_image_content_type"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hp_stores", :force => true do |t|
    t.string   "store_type"
    t.integer  "avant_advertiser_id"
    t.integer  "linkshare_advertiser_id"
    t.integer  "cj_advertiser_id"
    t.integer  "pj_advertiser_id"
    t.integer  "ir_advertiser_id"
    t.integer  "custom_advertiser_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ir_advertiser_category_mappings", :force => true do |t|
    t.integer  "ir_advertiser_id"
    t.integer  "product_category_id"
    t.boolean  "preferred"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ir_advertiser_category_mappings", ["ir_advertiser_id"], :name => "index_ir_category_mappings_on_adv_id"
  add_index "ir_advertiser_category_mappings", ["product_category_id"], :name => "index_ir_category_mappings_on_product_id"

  create_table "ir_advertisers", :force => true do |t|
    t.string   "name"
    t.string   "advertiser_id"
    t.boolean  "inactive"
    t.text     "params",                 :limit => 2147483647
    t.boolean  "mobile_enabled",                                                             :default => false
    t.float    "max_commission_percent"
    t.decimal  "max_commission_dollars",                       :precision => 8, :scale => 2
    t.string   "generic_link"
    t.string   "logo_file_name"
    t.datetime "logo_updated_at"
    t.integer  "logo_file_size"
    t.string   "logo_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ir_coupons", :force => true do |t|
    t.string   "advertiser_name"
    t.string   "advertiser_id"
    t.string   "header"
    t.string   "ad_id"
    t.string   "ad_url"
    t.string   "description"
    t.date     "start_date"
    t.date     "expires_at"
    t.string   "code"
    t.boolean  "manually_uploaded"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "linkshare_advertiser_category_mappings", :force => true do |t|
    t.integer "linkshare_advertiser_id"
    t.integer "product_category_id"
    t.boolean "preferred"
  end

  add_index "linkshare_advertiser_category_mappings", ["linkshare_advertiser_id"], :name => "index_linkshare_category_mappings_on_adv_id"
  add_index "linkshare_advertiser_category_mappings", ["product_category_id"], :name => "index_linkshare_category_mappings_on_product_id"

  create_table "linkshare_advertisers", :force => true do |t|
    t.string   "name"
    t.integer  "advertiser_id"
    t.string   "base_offer_id"
    t.string   "website"
    t.decimal  "max_commission_percent", :precision => 8, :scale => 2
    t.decimal  "max_commission_dollars", :precision => 8, :scale => 2
    t.text     "params"
    t.boolean  "inactive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_url"
  end

  add_index "linkshare_advertisers", ["advertiser_id"], :name => "index_linkshare_advertisers_on_advertiser_id"

  create_table "linkshare_coupons", :force => true do |t|
    t.string   "advertiser_name"
    t.integer  "advertiser_id"
    t.string   "ad_id"
    t.string   "ad_url"
    t.string   "header"
    t.string   "code"
    t.text     "description"
    t.date     "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manually_uploaded"
  end

  add_index "linkshare_coupons", ["ad_id"], :name => "index_linkshare_coupons_on_ad_id", :unique => true
  add_index "linkshare_coupons", ["advertiser_id"], :name => "index_linkshare_coupons_on_advertiser_id"

  create_table "mcb_updates", :force => true do |t|
    t.integer  "user_id"
    t.date     "alert_date"
    t.integer  "alertable_id"
    t.string   "alertable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "muddleme_transactions", :force => true do |t|
    t.string   "kind"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
    t.integer  "transactable_id"
    t.string   "transactable_type"
    t.decimal  "total_amount",      :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offer_images", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "offer_id"
    t.datetime "image_updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", :force => true do |t|
    t.string   "name"
    t.integer  "vendor_id"
    t.boolean  "product_offer",                                          :default => false
    t.string   "coupon_code"
    t.string   "offer_url"
    t.text     "offer_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                                             :default => false
    t.datetime "expiration_time"
    t.decimal  "total_spent",              :precision => 8, :scale => 2
    t.string   "offer_video_file_name"
    t.string   "offer_video_content_type"
    t.integer  "offer_video_file_size"
    t.datetime "offer_video_updated_at"
  end

  create_table "pj_advertiser_category_mappings", :force => true do |t|
    t.integer  "pj_advertiser_id"
    t.integer  "product_category_id"
    t.boolean  "preferred"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pj_advertiser_category_mappings", ["pj_advertiser_id"], :name => "index_pj_category_mappings_on_adv_id"
  add_index "pj_advertiser_category_mappings", ["product_category_id"], :name => "index_pj_category_mappings_on_product_id"

  create_table "pj_advertisers", :force => true do |t|
    t.string   "name"
    t.string   "advertiser_id"
    t.boolean  "inactive"
    t.text     "params",                 :limit => 2147483647
    t.boolean  "mobile_enabled",                                                             :default => false
    t.float    "max_commission_percent"
    t.decimal  "max_commission_dollars",                       :precision => 8, :scale => 2
    t.string   "generic_link"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_content_type"
    t.string   "logo_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pj_coupons", :force => true do |t|
    t.string   "advertiser_name"
    t.string   "advertiser_id"
    t.string   "header"
    t.string   "ad_id"
    t.string   "ad_url"
    t.string   "description"
    t.date     "start_date"
    t.date     "expires_at"
    t.string   "code"
    t.boolean  "manually_uploaded"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "printable_coupons", :force => true do |t|
    t.integer  "user_coupon_id"
    t.string   "coupon_image_content_type"
    t.string   "coupon_image_file_name"
    t.datetime "coupon_image_updated_at"
    t.integer  "coupon_image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.integer  "order"
    t.boolean  "popular",    :default => false
  end

  add_index "product_categories", ["ancestry"], :name => "index_product_categories_on_ancestry"

  create_table "product_categories_vendors", :force => true do |t|
    t.integer  "product_category_id"
    t.integer  "vendor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recognize_images", :force => true do |t|
    t.integer  "etilize_id"
    t.string   "etilize_image_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "best_buy_id"
    t.string   "best_buy_image_url"
    t.string   "best_buy_product_name"
  end

  create_table "referred_visits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "earnings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sales_group_id"
  end

  create_table "sales_groups", :force => true do |t|
    t.string   "name"
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_groups", ["user_id"], :name => "index_sales_groups_on_user_id"

  create_table "search_avant_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "avant_merchant_id"
    t.integer  "resulting_balance"
    t.float    "price"
    t.float    "commission_amount"
    t.integer  "search_intent_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_box_messages", :force => true do |t|
    t.text     "message"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_box_messages", ["user_id"], :name => "index_search_box_messages_on_user_id"

  create_table "search_cj_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "cj_merchant_id"
    t.integer  "resulting_balance"
    t.float    "price"
    t.float    "commission_amount"
    t.integer  "search_intent_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_intent_outcomes", :force => true do |t|
    t.integer  "intent_id"
    t.integer  "merchant_id"
    t.boolean  "purchase_made"
    t.datetime "confirmed_at"
    t.datetime "first_reminder_sent_at"
    t.datetime "second_reminder_sent_at"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_intents", :force => true do |t|
    t.string   "search",                                                                        :null => false
    t.integer  "user_id"
    t.date     "search_date",                                                                   :null => false
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "user_earnings",                :precision => 8, :scale => 2
    t.boolean  "has_active_service_merchants",                               :default => false
  end

  add_index "search_intents", ["search", "user_id", "search_date"], :name => "index_search_intents_on_search_and_user_id_and_search_date", :unique => true
  add_index "search_intents", ["search"], :name => "index_search_intents_on_search"
  add_index "search_intents", ["user_id"], :name => "index_search_intents_on_user_id"

  create_table "search_ir_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "ir_merchant_id"
    t.integer  "resulting_balance"
    t.float    "price"
    t.float    "commission_amount"
    t.integer  "search_intent_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_linkshare_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "linkshare_merchant_id"
    t.integer  "resulting_balance"
    t.float    "price"
    t.float    "commission_amount"
    t.integer  "search_intent_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_merchants", :force => true do |t|
    t.string   "company_name"
    t.string   "company_address"
    t.string   "company_url"
    t.string   "offer_name"
    t.string   "coupon_code"
    t.string   "company_phone"
    t.string   "user_money",                             :null => false
    t.string   "offer_buy_url"
    t.string   "company_coupons_url"
    t.integer  "intent_id",                              :null => false
    t.boolean  "active",              :default => false
    t.integer  "db_id"
    t.integer  "other_db_id"
    t.string   "type",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "params"
    t.string   "logo_url"
  end

  add_index "search_merchants", ["db_id"], :name => "index_search_merchants_on_db_id"
  add_index "search_merchants", ["intent_id"], :name => "index_search_merchants_on_intent_id"

  create_table "search_pj_commissions", :force => true do |t|
    t.string   "commission_id"
    t.integer  "pj_merchant_id"
    t.integer  "resulting_balance"
    t.float    "price"
    t.float    "commission_amount"
    t.integer  "search_intent_id_received"
    t.datetime "occurred_at"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_categories_vendors", :force => true do |t|
    t.integer  "service_category_id"
    t.integer  "vendor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sms_alerts", :force => true do |t|
    t.string   "from_phone_number"
    t.string   "receiver_phone_number"
    t.string   "status"
    t.string   "twilio_uri"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "soleo_categories", :force => true do |t|
    t.string   "name",                          :null => false
    t.integer  "soleo_id",                      :null => false
    t.string   "ancestry"
    t.integer  "ancestry_depth", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "soleo_categories", ["soleo_id", "ancestry_depth"], :name => "index_soleo_categories_on_soleo_id_and_ancestry_depth", :unique => true

  create_table "store_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.integer  "order"
    t.datetime "updated_at"
  end

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.integer  "storable_id"
    t.string   "storable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.integer  "user_id"
    t.integer  "answer_how_many_offers"
    t.integer  "answer_edu_level"
    t.integer  "answer_purchase_factor"
    t.integer  "answer_job_num"
    t.integer  "answer_delivery_preference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_settings", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_stats", :force => true do |t|
    t.string   "name"
    t.decimal  "value",      :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transfer_fees", :force => true do |t|
    t.integer  "feeable_id"
    t.string   "feeable_type"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_agent_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_agent"
    t.string   "browser_name"
    t.string   "browser_major_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_coupons", :force => true do |t|
    t.integer  "advertisable_id"
    t.string   "advertisable_type"
    t.string   "store_website"
    t.string   "offer_type"
    t.string   "code"
    t.text     "discount_description"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "static_score"
    t.float    "dynamic_score"
    t.string   "change_origin"
    t.text     "change_origin_params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_service_providers", :force => true do |t|
    t.integer  "user_id"
    t.string   "merchant_name"
    t.string   "merchant_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "phone"
  end

  create_table "user_settings", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "initiated_auction_mail"
    t.boolean  "ended_auction_mail"
    t.boolean  "bid_mail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "post_to_social"
  end

  create_table "user_transactions", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
    t.integer  "transactable_id"
    t.string   "transactable_type"
    t.decimal  "total_amount",      :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                         :default => "",    :null => false
    t.string   "encrypted_password",                                            :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_uid"
    t.string   "facebook_token"
    t.string   "twitter_uid"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.string   "google_uid"
    t.string   "google_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "phone"
    t.string   "sex"
    t.string   "age_range"
    t.decimal  "balance",                         :precision => 8, :scale => 2
    t.integer  "sign_in_count",                                                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "favourite_browser_name"
    t.string   "favourite_browser_major_version"
    t.integer  "referred_visit_id"
    t.string   "education"
    t.string   "occupation"
    t.string   "income_range"
    t.string   "marital_status"
    t.string   "family_size"
    t.boolean  "home_owner"
    t.boolean  "blocked",                                                       :default => false
    t.integer  "score"
    t.string   "state_abbreviation"
    t.boolean  "from_university_landing_page"
    t.integer  "image_file_size"
    t.string   "image_file_name"
    t.datetime "image_updated_at"
    t.string   "image_content_type"
    t.boolean  "donate_enabled",                                                :default => true
    t.boolean  "sales_owner",                                                   :default => false
    t.string   "sales_name"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vendor_funds_grants", :force => true do |t|
    t.decimal  "amount",     :precision => 8, :scale => 2
    t.integer  "vendor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendor_keywords", :force => true do |t|
    t.integer  "vendor_id"
    t.string   "keyword"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendor_settings", :force => true do |t|
    t.integer  "vendor_id"
    t.boolean  "recommended_auctions_mail"
    t.boolean  "auction_status_mail"
    t.boolean  "auction_result_mail"
    t.boolean  "contact_info_mail"
    t.boolean  "auto_bid_mail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_confirm_outcomes"
  end

  create_table "vendor_tracking_events", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "auction_id"
    t.string   "event_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendor_transactions", :force => true do |t|
    t.integer  "vendor_id"
    t.decimal  "amount",            :precision => 8, :scale => 2
    t.decimal  "resulting_balance", :precision => 8, :scale => 2
    t.integer  "transactable_id"
    t.string   "transactable_type"
    t.decimal  "total_amount",      :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendors", :force => true do |t|
    t.string   "email",                                                        :default => "",    :null => false
    t.string   "encrypted_password",                                           :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_uid"
    t.string   "facebook_token"
    t.string   "twitter_uid"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.string   "google_uid"
    t.string   "google_token"
    t.string   "company_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "phone"
    t.string   "website_url"
    t.decimal  "balance",                        :precision => 8, :scale => 2
    t.boolean  "service_provider",                                             :default => false
    t.boolean  "retailer",                                                     :default => false
    t.integer  "sign_in_count",                                                :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "low_funds_notification_sent_at"
    t.datetime "recommendations_sent_at"
    t.string   "review_url"
    t.boolean  "blocked",                                                      :default => false
    t.string   "state_abbreviation"
  end

  add_index "vendors", ["confirmation_token"], :name => "index_vendors_on_confirmation_token", :unique => true
  add_index "vendors", ["email"], :name => "index_vendors_on_email", :unique => true
  add_index "vendors", ["reset_password_token"], :name => "index_vendors_on_reset_password_token", :unique => true

  create_table "withdrawal_requests", :force => true do |t|
    t.integer  "user_id"
    t.string   "paypal_email"
    t.integer  "amount"
    t.integer  "user_balance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zip_codes", :force => true do |t|
    t.string   "code"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zip_codes", ["code"], :name => "index_zip_codes_on_code", :unique => true

end
