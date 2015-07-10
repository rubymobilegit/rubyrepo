class Users::ProfileController < ApplicationController
  before_filter :authenticate_user!


  def show

  end

  def update
    @user = current_user
    @user.dont_require_password = true if params[:password].nil?
    if @user.update_attributes(params[:user])
      sign_in @user, :bypass => true
      redirect_to profile_url, :notice => 'Profile was successfully updated.'
    else
      render :action => "show"
    end

  end

  def contact_info

  end

  def update_contact_info
    @user = current_user
    @user.dont_require_password = true if params[:password].nil?
    if @user.update_attributes(params[:user])
      sign_in @user, :bypass => true
      redirect_to contact_info_profile_url, :notice => 'Contact info was successfully updated.'
    else
      render :action => "contact_info"
    end
  end

  def update_password
    @user = current_user
    if @user.update_with_password(params[:user])
      sign_in(@user, :bypass => true)
      redirect_to contact_info_profile_url, :notice => "Password has been successfully updated."
    else
      render :action => "contact_info"
    end

  end

  def submit_coupon
    @advertiser = params[:advertiser_type].constantize.where("id =?", params[:advertiser_id]).first if params[:advertiser_type].present? && params[:advertiser_id].present?
    @store_link = get_store_link(@advertiser, params[:advertiser_type])
    @user_coupon = @advertiser.user_coupons.new if @advertiser.present?
    @user_coupon = UserCoupon.new if @user_coupon.blank?
    render :layout => 'new_resp_popup'
  end

  def save_coupon
    @status = false
    @message = ''
    spam_status = UserCoupon.check_spam_in_discount_description(params[:discount_description])
    if !spam_status
      if verify_recaptcha
        @user_coupon = UserCoupon.new(
          :advertisable_id => params[:advertisable_id],
          :advertisable_type => params[:advertisable_type],
          :code => params[:code],
          :discount_description => params[:discount_description],
          :expiration_date => format_date_from_datepicker(params[:expiration_date]),
          :store_website => params[:store_website],
          :offer_type => params[:offer_type]
        )
        if @user_coupon.save
          if @user_coupon.offer_type == 'Printable Coupon'
            PrintableCoupon.create!(:user_coupon_id => @user_coupon.id, :coupon_image => params[:printable_coupon])
          end
          @status = true
          @message = 'Coupon was successfully added'
        else
          @message = 'Coupon was not added. Please try again'
        end
      else
        @message = 'The recaptcha did not match'
      end
    else
      @message = 'The description entered for coupon did not pass spam filter'
    end
    respond_to do |format|
      format.js
      format.html{ render :layout => false }
    end
  end

  def get_store_link(advertiser, advertiser_type)
    store_link = ''
    if advertiser.present? && advertiser_type.present?
      case advertiser_type
        when 'IrAdvertiser' then
          store_link = advertiser.params['AdvertiserUrl'] if advertiser.params.present?
        when 'LinkshareAdvertiser' then
          store_link = advertiser.website
        when 'CjAdvertiser' then
          store_link = advertiser.params['program_url'] if advertiser.params.present?
        when 'AvantAdvertiser' then
          store_link = advertiser.advertiser_url
        when 'PjAdvertiser' then
          store_link = advertiser.params['website'] if advertiser.params.present?
      end
    end
    store_link
  end

  def format_date_from_datepicker(date_str)
    Date::strptime(date_str, "%m/%d/%y") if date_str.present?
  end

end
