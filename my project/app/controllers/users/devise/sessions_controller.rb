class Users::Devise::SessionsController < Devise::SessionsController
  before_filter :only => "create" do
    sign_out :vendor
    sign_out :admin
  end
  #go to vendor login page if vendor logged in
  before_filter :only => "new" do
    redirect_to :controller=>'vendors/devise/sessions', :action=>'new' unless current_vendor.nil?
    redirect_to :controller=>'admins/devise/sessions', :action=>'new' unless current_admin.nil?
  end

  after_filter :only => "create" do
    set_notifications
    save_user_agent_information
  end

  # =========== Ajax login/logout ===========
  def create
    if request.xhr? || request['_xhr']
      resource = warden.authenticate!(:scope => resource_name)
      sign_in_and_render_json(resource_name, resource)
    else
      super
    end
    cookies[:signed_in] = 1
    #Search::ReferralNotificationBoxMessage.create(:message => Search::ReferralNotificationBoxMessage::DEFAULT_MESSAGE.sub('xxx', '$12'), :user_id => resource.id)
  end

  def destroy
    if request.xhr? || request['_xhr']
      sign_out resource_name
      render :nothing => true
    else
      super
    end
    cookies.delete(:signed_in)
    reset_session
  end

  def sign_in_and_render_json(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    render :json => {:success => true}
  end
  # =========== End of Ajax login ===========


  private

  def set_notifications
    finished_auctions = current_user.auctions.includes(:user).where('auctions.end_time < UTC_TIMESTAMP() AND auctions.end_time > users.last_sign_in_at').count
    session[:finished_auctions] = finished_auctions if (finished_auctions > 0)
  end

  def save_user_agent_information
    return if current_user.user_agent_logs.count >= UserAgentLog::LOG_COUNT
    current_user.dont_require_password = true

    browser = Browser.new(:accept_language => request.headers["Accept-Language"], :ua => request.headers["User-Agent"])

    UserAgentLog.create(
        :user_id => current_user.id,
        :user_agent => request.headers["User-Agent"],
        :browser_name => browser.name,
        :browser_major_version => browser.version
    )

    logs = current_user.user_agent_logs

    if logs.count == 1
      current_user.update_attributes(:favourite_browser_name=> browser.name, :favourite_browser_major_version=>browser.version)
    else
      frequency = {}

      logs.each do |l|
        frequency["#{l.browser_name} #{l.browser_major_version}"] = (frequency["#{l.browser_name} #{l.browser_major_version}"].nil? ? 1 : frequency["#{l.browser_name} #{l.browser_major_version}"]+1)
      end

      max = 0
      max_name = ""

      frequency.each do |f|
        if f[1] > max
          max = f[1]
          max_name = f[0]
        end
      end

      favourite = current_user.user_agent_logs.where(:browser_name=>current_user.favourite_browser_name, :browser_major_version=>current_user.favourite_browser_major_version).count

      if favourite >= max
        return
      elsif favourite < max
        current_user.update_attributes(:favourite_browser_name=> max_name.split(" ")[0], :favourite_browser_major_version=>max_name.split(" ")[1])
      end

    end
  end

end
