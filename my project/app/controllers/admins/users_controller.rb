class Admins::UsersController < ApplicationController
  before_filter :authenticate_admin!

  def download_csv
    users = User.select([:first_name, :last_name, :email]).order([:first_name, :last_name]).all
    respond_to do |format|
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          users.each do |u|
            csv << [u.full_name, u.email]
          end
        end
        send_data csv_string, :filename => 'users_emails.csv'
      end
    end
  end

  def become
    return unless current_admin
    sign_out current_admin
    sign_in User.find(params[:id]), :bypass => true
    redirect_to root_url, :notice => "You are signed as #{current_user.full_name} now."
  end

  def become_sales_owner
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attribute :sales_owner, true
        format.html { redirect_to admin_users_path, :notice => "User was set as sales owner successfully." }
      else
        format.html { redirect_to admin_users_path, :alert => "Unable to set as sales owner." }
      end
    end
  end

  def become_not_sales_owner
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attribute :sales_owner, false
        format.html { redirect_to (params[:sales] ? admin_sales_links_path : admin_users_path), :notice => "User was set as not sales owner successfully." }
      else
        format.html { redirect_to (params[:sales] ? admin_sales_links_path : admin_users_path), :alert => "Unable to set as not sales owner." }
      end
    end
  end

  def index
    list
  end

  def show
    @user = User.find(params[:id])
    @type = :user
    @searches = @user.search_intents.order('updated_at desc').paginate(:page => params[:search_page], :per_page => 10)
    @outcome_reports = Search::IntentOutcome.includes(:intent).joins('inner join search_merchants on search_intent_outcomes.merchant_id = search_merchants.id').joins(:intent).joins('inner join users on users.id = search_intents.user_id').where('search_intents.status != "released"').where('search_intents.user_id = ?', @user.id).order('search_intent_outcomes.updated_at desc').paginate(:page => params[:outcome_reports_page], :per_page => 10)
    list_earnings_and_withdrawals(@user)
  end

  def release_money
    @user = User.find(params[:id])
    @report = Search::IntentOutcome.find(params[:intent_outcome_id])
    @intent = @report.intent
    if params['to_release']
      total = 0
      params['to_release'].each do |val|
        total += val.to_f
      end
      @intent.release_from_soleo(total)
      flash[:notice] = 'Successfully released ' + (ActionController::Base.helpers.number_to_currency total.to_s)
      redirect_to :action => :show and return
    end
    @selected_merchant = @report.selected_merchant
    @merchants = @intent.merchants
  end

  def show_search
    @search = Search::Intent.find(params[:search_intent_id])
    @user = @search.user
    @merchants = @search.merchants.order('type desc')
  end

  def make_merchant_active
    merchant = Search::Merchant.find(params[:merchant_id])
    search = merchant.intent
    user = search.user
    merchant.active = true
    merchant.save
    search.has_active_service_merchants = merchant.type == Search::SoleoMerchant.name || merchant.type == Search::LocalMerchant.name
    search.status = Search::Intent::STATUSES[0] if merchant.intent.status.nil? # active
    search.save
    redirect_to "/admin/customers/#{user.id}/searches/#{search.id}"
  end

  def block
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attribute :blocked, true
        format.html { redirect_to admin_users_path, :notice => "User was blocked successfully." }
      else
        format.html { redirect_to admin_users_path, :alert => "Unable to block user." }
      end
    end
  end

  def unblock
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attribute :blocked, false
        format.html { redirect_to admin_users_path, :notice => "User was unblocked successfully." }
      else
        format.html { redirect_to admin_users_path, :alert => "Unable to unblock user." }
      end
    end
  end

  def add_money
    user = User.find(params[:id])
    amount = params[:commission_amount]
    if /^[+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?$/.match(amount)
      commission = AdminCommission.create(:commission_amount => amount.to_f, :user_id => user.id)
      UserTransaction.create_for commission
      MuddlemeTransaction.create_for commission
      redirect_to admin_user_path(user), :notice => 'Money was added successfully.'
    else
      redirect_to admin_user_path(user), :alert => 'Invalid money value.'
    end
  end

  private

  def list types=[:all], per_page=10
    sort_by = ['id', 'first_name', 'last_name', 'email', 'address', 'zip_code', 'sex']

    types.each do |type|
      params[:"#{type}_order"] = 'id' if params[:"#{type}_order"].blank?
      dir = instance_variable_set "@#{type}_dir", :DESC
      if params[:"#{type}_order"] && sort_by.include?(params[:"#{type}_order"])
        instance_variable_set "@#{type}_order", params[:"#{type}_order"]
        instance_variable_set "@#{type}_order_str", 'users.id' if params[:"#{type}_order"] == 'id'
      end
      ord = instance_variable_get "@#{type}_order"
      ord_str = instance_variable_get "@#{type}_order_str"
      dir = instance_variable_set "@#{type}_dir", params[:"#{type}_dir"] == 'DESC' ? :DESC : :ASC unless params[:"#{type}_dir"].blank?

      list = User

      list = list.search(params[:search]) unless params[:search].blank?

      list = list.order("#{ord_str || ord} #{dir}").paginate(:page=>params[:"#{type}_page"], :per_page=>per_page)
      instance_variable_set("@users_#{type}", list)
    end
  end

end
