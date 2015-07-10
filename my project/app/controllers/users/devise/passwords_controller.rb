class Users::Devise::PasswordsController < Devise::PasswordsController
  def create
    if request.xhr? || request['_xhr']
      self.resource = resource_class.find_by_email(params[resource_name][:email])
      if resource && (resource.reset_password_sent_at.nil? || Time.now > resource.reset_password_sent_at + 5.minutes)
        self.resource = resource_class.send_reset_password_instructions(params[resource_name])
        if successfully_sent?(resource)
          render :json => {:success => true, :message => 'You will receive an email with instructions about how to reset your password in a few minutes.'}
        else
          render :json => {:success => false, :message => 'Error. Try again later.'}
        end
      else
        render :json => {:success => false, :message => 'User not found.'}
      end
    else
      super
    end
  end
end
