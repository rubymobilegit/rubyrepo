#server "108.171.184.148", :app, :web, :db, :primary => true
server "166.78.107.196", :app, :web, :db, :primary => true

#set :user, "application"
set :use_sudo, false
set :environment, "production"
set :rails_env, "production"
set :branch, 'pepperjam_integration'
set :deploy_to,   "/home/#{user}/#{application}_#{rails_env}"


set :app_db_database, 'application'
set :app_db_host, "localhost"
set :app_db_username, "application"
set :app_db_password, "uov8ieDu"

set :fb_app_id, '444018178973901'
set :fb_app_secret, 'a61c8b011bf6353250161840def2c670'
set :tw_consumer_key, 'cELQnUxVThUU4zeGmB2XuA'
set :tw_consumer_secret, 'Jnl0XjPiU02ITZDWsazbP2qsxxzCAb7JSOTjY6aAkE'
set :g_consumer_key, '648763776892.apps.googleusercontent.com'
set :g_consumer_secret, 'e37lEFUQcWdZ7UHVwkXrapwu'

set :paypal_login, 'kevin_api1.muddleme.com'
set :paypal_password, 'FJSUHS44CVCMT6KN'
set :paypal_signature, 'AFcWxV21C7fd0v3bYYYRCpSSRl31A6PbmCghMzJ3F-vAxF38niR-SXqv'
set :authorize_login, '6Y5g6H4Uun'
set :authorize_password, '5bB6be6436uH7aCE'
set :merchant_production_mode, true

set :hostname_hostname, 'muddleme.com'
set :hostname_full_hostname, 'muddleme.com'
