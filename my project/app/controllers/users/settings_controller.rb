class Users::SettingsController < ApplicationController
  before_filter :authenticate_user!


  def new
    unless current_user.user_setting.nil?
      redirect_to :action=>:edit
      return
    end
    @user_setting = current_user.build_user_setting current_settings
    render :action => "edit"
  end

  def edit
    if current_user.user_setting.nil?
      redirect_to :action=>:new
      return
    end
    @user_setting = current_user.user_setting
    @user_setting.attributes = current_settings
  end


  def create
    @user_setting = current_user.build_user_setting(params[:user_setting])

    if @user_setting.save
      redirect_to url_for(:controller=>'users/settings', :action=>'edit'), :notice => 'Your settings were successfully saved.'
    else
      render :action => "edit"
    end
  end

  def update
    @user_setting = current_user.user_setting

    if @user_setting.update_attributes(params[:user_setting])
      redirect_to url_for(:controller=>'users/settings', :action=>'edit'), :notice => 'Your settings were successfully updated.'
    else
      render :action => "edit"
    end
  end
  
  private
  def current_settings
    {
      :initiated_auction_mail => current_user.initiated_auction_mail?,
      :ended_auction_mail => current_user.ended_auction_mail?,
      :bid_mail => current_user.bid_mail?,
      :post_to_social => current_user.post_to_social?
    }
  end

end