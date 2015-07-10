#server "muddleme.rightproject.net", :app, :web, :db, :primary => true
server "166.78.107.196", :app, :web, :db, :primary => true

#set :user, "application"
set :use_sudo, false
set :environment, "production"
set :rails_env, "production"
set :branch, "new_home_page"
set :deploy_to,   "/home/#{user}/#{application}_staging"

set :app_db_database, 'application'
set :app_db_host, "localhost"
set :app_db_username, "application"
set :app_db_password, "uov8ieDu"

set :fb_app_id, '178663265569332'
set :fb_app_secret, 'e347a6043983f352e22eef8f49bda3f8'
set :tw_consumer_key, 'sRi4RDEdd7M8OAPomSAKmA'
set :tw_consumer_secret, '3Vugle6oCAqh3ZJhCVP4v6m7yEqmdaEKnWvvbBSo'
set :g_consumer_key, '651565860187.apps.googleusercontent.com'
set :g_consumer_secret, 'LkTU2N0SKWHkvq3uMK-AS0lE'

set :paypal_login, '4gambi_1337953814_biz_api1.gmail.com'
set :paypal_password, '1337953855'
set :paypal_signature, 'AiPC9BjkCyDFQXbSkoZcgqH3hpacA.YiSEypTMI7xcZezZIlEDF3TDcW'
set :authorize_login, '92QkxMqZ5F7S'
set :authorize_password, '98yEe334CBX2BGwJ'
set :merchant_production_mode, false

set :hostname_hostname, '166.78.107.196'
set :hostname_full_hostname, '166.78.107.196'
