class Api < Grape::API
  format :json
  error_format :json

  # 500 errors
  rescue_from :all do |error|
    Rack::Response.new([ error.to_s ], 500)
  end

  helpers do
    def warden
      env['warden']
    end
    
    def authenticated
      if warden.authenticated?
        return true
      else
        error!('401 Unauthorized', 401)
      end
    end
    
    def current_user
      warden.user
    end

    def api_error!(message, code)
      error!({:error => message, :code => code}, code)
    end


    def list_auctions options = {}
      sort_by = ['id','name', 'product_auction', 'max_vendors', 'budget', 'end_time', 'category']

      options = {
        :type=>'in_progress',
        :page=>1,
        :per_page=>30,
        :order_by=>'id',
        :order_dir=>'desc',
      }.merge(options.to_hash.symbolize_keys)

      options[:type] = options[:type].to_sym
      unconfirmed_where_cond = 'auctions.end_time > ? AND ('
      unconfirmed_where_cond += 'auctions.status = "unconfirmed" OR '
      unconfirmed_where_cond += 'auctions.status = "resolved") '
      # unconfirmed_where_cond += 'auctions.status = "resolved" AND '
      # unconfirmed_where_cond += '(cj_offers.id IS NOT NULL OR avant_offers.id IS NOT NULL)))'
      where_conds = {
        :in_progress => 'auctions.end_time >= UTC_TIMESTAMP() ',
        :finished => 'auctions.end_time < UTC_TIMESTAMP() AND status<>"active"',
        :unconfirmed => ['auctions.end_time > ? AND auctions.status = "unconfirmed"', Time.now - Auction::CANT_CONFIRM_AFTER]
      }

      options[:order_by] = 'id' if sort_by.include?(options[:order_by])

      order = case options[:order_by]
      when 'id'
        'auctions.id'
      when 'product_auction'
        '!product_auction'
      when 'category'
        'IF(auctions.product_auction, product_categories.name, service_categories.name)'
      else
        options[:order_by]
      end

      dir = options[:order_dir].downcase == 'asc' ? :ASC : :DESC

      options[:page] = options[:page].to_i
      options[:page] = 1 if options[:page] < 1

      options[:per_page] = options[:per_page].to_i
      options[:per_page] = 30 if options[:per_page] < 1
      options[:per_page] = 100 if options[:per_page] > 100

      list = current_user.auctions.where(where_conds[options[:type]] || where_conds[:in_progress]).
        includes(:service_category, :product_category, {:outcome=>:vendor_outcomes},
          :auction_images, {:bids=>[:vendor, :offer]}, {:winning_bids=>[:vendor, :offer]},
          {:cj_offers=>{:advertiser=>:coupons}}, {:avant_offers=>{:advertiser=>:coupons}}).
        order("#{order} #{dir}").paginate(:page=>options[:page], :per_page=>options[:per_page])
    end

    def format_datetime value
      value && value.strftime('%m/%d/%Y at %R')
    end
  end
  
  desc "Logs user in."
  # params do
  #  requires :login, :type => String, :desc => "User login."
  #  requires :password, :type => String, :desc => "User password."
  # end
  post '/login' do
    params[:user] ||= {}
    user = User.find_for_database_authentication(:email=>params[:user][:email])
    if user && user.valid_password?(params[:user][:password])
      warden.session_serializer.store(user, :user)
      current_user.to_api_json
    else
      false
    end
  end
  
  desc "Logs user out."
  post '/logout' do
    user = warden.user(:scope => 'user', :run_callbacks => false) # If there is no user
    warden.raw_session.inspect # Without this inspect here. The session does not clear.
    warden.logout('user')
    warden.clear_strategies_cache!(:scope => 'user')
    !!user
  end

  desc "Get current user or oauth data"
  get '/oauthuser' do
    if current_user
      {:user => current_user.to_api_json}
    else
      session = warden.raw_session
      {:oath_data => User.new_with_session({}, session)}
    end
  end

  desc "Check if email is valid"
  get '/email_available' do
    error!("email param not present in reuqest", 400) if params[:email].blank?
    User.find_by_email(params[:email]).blank?
  end

  desc "Get help and contact html"
  get '/help_and_contact_html' do
    setting = SystemSettings.find_by_name('mobile_help_content')
    return {:html=>''} if setting.blank?
    {:html=>setting.value}
  end

  desc "Get current user"
  get '/user' do
    authenticated
    current_user.to_api_json
  end

  desc "Update user attributes"
  put '/user' do
    authenticated
    user = current_user
    params[:user] ||= {}
    params[:user].delete :password
    user.dont_require_password = true
    if user.update_attributes(params[:user])
      warden.session_serializer.store(user, :user)
      current_user.to_api_json
    else
      error!(user.errors.to_a, 400)
    end
  end

  desc "Register user"
  post '/user' do
    if current_user
      user = warden.user(:scope => 'user', :run_callbacks => false) # If there is no user
      warden.raw_session.inspect # Without this inspect here. The session does not clear.
      warden.logout('user')
      warden.clear_strategies_cache!(:scope => 'user')
    end
    hash ||= params[:user] || {}
    session = warden.raw_session
    user = User.new_with_session hash, session
    user.dont_require_password_confirmation = true
    if user.save
      warden.session_serializer.store(user, :user)
      current_user.to_api_json
    else
      error!(user.errors.to_a, 400)
    end
  end

  desc "auctions list"
  # params do
  #   optional :type
  #   optional :page
  #   optional :per_page
  #   optional :order_by
  #   optional :order_dir
  # end
  get '/auctions' do
    authenticated
    list = list_auctions params
    {
      :auctions => list.map(&:to_api_json),
      :total_items => list.total_entries,
      :page => list.current_page
    }
  end

  desc "auction details"
  get '/auction/:id' do
    authenticated
    auction = current_user.auctions.find(params[:id])
    auction.to_api_json
  end

  desc "create auction"
  post '/auctions' do
    authenticated
    params[:auction] ||= {}
    images = params[:auction].delete(:auction_images) || []

    auction = current_user.auctions.build params[:auction]
    auction.from_mobile = true

    error!(auction.errors.to_a, 400) if !auction.save
    auction.delay_fetch_affiliate_offers
    
    images.each do |img|
      error!('No image data for auction image', 400) if img[:image].blank?
      error!('Image file name cannot be blank', 400) if img[:file_name].blank?
      stream = StringIO.new(Base64.decode64(img[:image]))
      auction_image = current_user.auction_images.build :auction => auction
      auction_image.image = stream
      auction_image.image.instance_write(:content_type, img[:content_type])
      auction_image.image.instance_write(:file_name, img[:file_name])
      error!(auction_image.errors.to_a, 400) if !auction_image.save
    end

    auction.to_api_json
  end

  desc "provide auction outcome"
  #params
  # :outcome=>{
  #   :purchase_made=>true/false
  #   :vendor_id=>vendor_id
  #   :comment=> (optional)
  # }
  post "/auction/:id/outcome" do
    authenticated
    auction = current_user.auctions.find(params[:id])
    if auction.outcome.nil? || auction.status != 'unconfirmed'
      error!('This auction is unconfirmable', 403)
      return
    end
    params[:outcome] ||={}

    outcome = auction.outcome
    vendor_id = params[:outcome].delete :vendor_id
    outcome.attributes = params[:outcome]
    if outcome.purchase_made
      begin
      outcome.vendor_ids = (outcome.vendor_ids + vendor_id.to_a).uniq
      rescue ActiveRecord::RecordInvalid
        error!('Validatin errors: ' + outcome.vendor_outcomes.first.errors.to_a.join(' '), 400)
      end
    end
    outcome.confirmed_at = Time.now

    if outcome.save
      if outcome.auction.errors[:status].blank?
        vendor_outcome = outcome.vendor_outcomes.where('accepted IS NULL').first
        unless vendor_outcome.nil?
          if vendor_outcome.auto_accepted
            vendor_outcome.update_attribute :accepted, true
          else
            AuctionsMailer.delay.vendor_confirm_outcome(auction, vendor_outcome.vendor) if EmailContent.vendor_confirm_outcome_mail?
          end
        end
        Admins::AuctionsMailer.delay.user_provide_auction_outcome(auction, outcome) unless outcome.comment.blank? #send mail to support only if comment is not blank
        auction.reload.to_api_json
      else
        alert = "The deadline for confirming the outcome of this auction"
        alert += " expired #{format_datetime(auction.end_time + Auction::CANT_CONFIRM_AFTER)}"
        error!(alert, 403)
      end
    else
      error!('Validatin errors: ' + outcome.errors.to_a.join(' '), 400)
    end
  end

  desc "rsolve auction"
  get "/auction/:id/resolve" do
    authenticated
    auction = current_user.auctions.find(params[:id])

    auction.resolve_auction true
    auction.to_api_json
  end

  desc "coupons for offer"
  get "/offer_coupons/:type/:offer_id" do
    authenticated
    if !['cj','avant'].include?(params[:type])
      error!("Invalid type must be 'cj' or 'avant'", 400)
    else
      offer = current_user.send("#{params[:type]}_offers").find(params[:offer_id])
      offer.advertiser.coupons.map(&:to_api_json)
    end
  end

  desc "coupons for advertiser"
  get "/advertiser_coupons/:type/:advertiser_id" do
    authenticated
    if !['cj','avant'].include?(params[:type])
      error!("Invalid type must be 'cj' or 'avant'", 400)
    else
      advertiser = "#{params[:type].capitalize}Advertiser".constantize.find(params[:advertiser_id])
      advertiser.coupons.map(&:to_api_json)
    end
  end

  desc "get all service categories"
  get '/service_categories' do
    ServiceCategory.all.map{|c| {:id=>c.id, :name=>c.name}}
  end

  desc "get all product categories"
  get '/product_categories' do
    #should probably be more clever
    #but for now just hardocoded 3 
    ProductCategory.roots.order('`order` ASC').map do |root|
      subtree = root.children.order('`order` ASC').map do |child|
        subsubtree = child.children.order('`order` ASC').map{|c| {:id => c.id,:name => c.name}}
        {:id => child.id,:name => child.name,:children=>subsubtree}
      end
      {:id => root.id,:name => root.name,:children => subtree}
    end
  end

  desc "send email invitations to muddle with referral link"
  #param contacts => []
  post '/referrals/invite_emails' do
    authenticated
    params[:contacts] ||= []
    recipients = params[:contacts].to_a
    error_mails = []
    recipients.each_with_index do |email, idx|
      error_mails.push recipients.delete_at(idx) if (email =~ /\A.+@.+\..+\Z/).nil?
    end

    unless recipients.empty?
      ReferralsMailer.invite(current_user, recipients).deliver
    end
    result = {}
    recipients.each { |r| result[r] = true }
    error_mails.each { |r| result[r] = false }
    result
  end

  desc "get product name from recognize.im image id"
  get '/recognized_product/:id' do
    image = RecognizeImage.find params[:id]
    {
      :name=>image.best_buy_product_name,
      :images=>[{:url=>image.best_buy_image_url, :type=>'large'}]
    }
  end

  desc "deprecated for now get product name from recognize.im image id"
  get '/etilize_recognized_product/:id' do
    image = RecognizeImage.find params[:id]
    etilize_product = Etilize.product(image.etilize_id)['Product']
    images = etilize_product['resources']['resource']
    images = [images] if !images.is_a? Array
    images.delete_if {|i| i['status'] != 'Published'}
    {
      :name=>etilize_product['descriptions']['description']['__content__'],
      :images=>images.map{|i| {:url=>i['url'], :type=>i['type']}}
    }
  end
end