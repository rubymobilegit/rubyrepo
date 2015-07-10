require 'capistrano/ext/multistage'
require 'bundler/capistrano'
#require 'rvm/capistrano'
#require "whenever/capistrano"
#require "delayed/recipes"

set :application, 'muddleme'
#set :stages, %w(production staging)
#set :default_stage, 'production'

#ssh stuff
set :user, 'developer'
set :password, 'PLMMFX502'
set :port, 22
set :scm, :git
set :use_sudo, false
default_run_options[:pty] = true
set :default_shell, '/bin/bash -l'
set :repository, 'git@bitbucket.org:kevinbrothers/muddleme_final.git'
set :deploy_via, :remote_cache
#set :branch, 'pepperjam_integration'
#set :rails_env, 'production'
#set :deploy_to,   "/home/#{user}/#{application}_#{rails_env}"
set :shared_children, shared_children + %w{public/system}

# will be different entries for app, web, db if you host them on different servers
#server 'muddleme.com', :app, :web, :primary => true

set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
namespace :deploy do
  after 'deploy:restart', 'deploy:cleanup'
  task :restart, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  after 'deploy:update_code' do
    run "cd #{release_path} && #{try_sudo} RAILS_ENV=#{rails_env} bundle exec whenever --clear-crontab #{application}"
    run "cd #{release_path} && #{try_sudo} RAILS_ENV=#{rails_env} bundle exec whenever --update-crontab #{application}"
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} #{assets_dependencies.join ' '} | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end
