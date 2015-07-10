class Admins::Devise::SessionsController < Devise::SessionsController
  before_filter :only => "create" do
    sign_out :vendor
    sign_out :user
  end

  before_filter :only => "new" do
    redirect_to :controller=>'vendors/devise/sessions', :action=>'new' unless current_vendor.nil?
    redirect_to :controller=>'users/devise/sessions', :action=>'new' unless current_user.nil?
  end

end
