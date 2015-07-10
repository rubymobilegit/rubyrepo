class Users::Devise::RegistrationsController < Devise::RegistrationsController

  after_filter :only => "create" do
    post_to_wall
  end

  # =========== Ajax sign up ===========
  def create
    if request.xhr? || request['_xhr']
      build_resource
      resource.dont_require_password_confirmation = true
      if resource.save
        sign_in(resource_name, resource)
        set_referred_visit
        render :json => {:success => true}
      else
        render :json => {:success => false, :message => resource.errors.full_messages.join(', ')} and return
      end
    else
      super
    end
    cookies[:signed_in] = 1
  end
  # =========== Ajax sign up ===========


  def after_sign_up_path_for(resource_name)
    if session[:university_page_visited]
      current_user.update_attribute :from_university_landing_page, true
    end
    set_referred_visit
    root_path
  end

  def set_referred_visit
    if session[:referred_visit_id] && visit = ReferredVisit.find_by_id(session[:referred_visit_id])
      current_user.referred_visit = visit
      current_user.save!
    end
  end

  private

  def post_to_wall
    post_to_facebook
    post_to_twitter
  end

  def post_to_facebook
    unless resource.facebook_uid.blank? || resource.facebook_token.blank?
      begin
        user = FbGraph::User.new(resource.facebook_uid, :access_token => resource.facebook_token)
        user.feed!(
            :message => 'I signed up to MuddleMe. I get the best deals AND make few extra bucks. You should check it out',
            :link => 'http://muddleme.com',
            :name => 'MuddleMe',
            :description => 'MuddleMe'
        )
      rescue Exception => e
        return false
      end

    end
  end

  def post_to_twitter
    unless resource.twitter_uid.blank? || resource.twitter_token.blank? || resource.twitter_secret.blank?
      begin
        client = Twitter::Client.new(
            :oauth_token => resource.twitter_token,
            :oauth_token_secret => resource.twitter_secret
        )
        client.update('I signed up to MuddleMe. I get the best deals AND make few extra bucks. You should check it out: muddleme.com')
      rescue Exception => e
        return false
      end
    end
  end

end