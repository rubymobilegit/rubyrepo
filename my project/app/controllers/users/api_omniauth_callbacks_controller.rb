class Users::ApiOmniauthCallbacksController < ApplicationController
  layout '/layouts/empty'

  def facebook
    omniauth = request.env["omniauth.auth"]
    @user = User.find_for_facebook_oauth(omniauth, current_user)

    if @user && @user.persisted?
      sign_in @user
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
    end
    render :callback
  end

  def twitter
    omniauth = request.env["omniauth.auth"]
    @user = User.find_for_twitter_oauth(omniauth, current_user)

    if @user && @user.persisted?
      sign_in @user
    else
      data = request.env["omniauth.auth"]
      data.delete :extra
      session["devise.twitter_data"] = data
    end
    render :callback
  end

  def google_oauth2
    omniauth = request.env["omniauth.auth"]
    @user = User.find_for_google_oauth(omniauth, current_user)

    if @user && @user.persisted?
      sign_in @user
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
    end
    render :callback
  end

  def failure
    set_flash_message :alert, :failure, :kind => failed_strategy.name.to_s.humanize, :reason => failure_message
    redirect_to root_path
  end

end