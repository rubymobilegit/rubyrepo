class User < ActiveRecord::Base

  include EncodableModelIds

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :validatable, :encryptable, :omniauthable, :trackable

  attr_accessor :dont_require_password_confirmation, :dont_require_password

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :address, :city, :zip_code, :sex, :phone,
    :terms, :age_range, :favourite_browser_name, :favourite_browser_major_version, :state_abbreviation,
    :education, :occupation, :income_range, :marital_status, :family_size, :home_owner,
    :auctions_attributes

  has_many :auctions, :dependent=>:restrict
  has_many :auction_images, :dependent=>:destroy, :conditions => "auction_id is null"
  has_many :cj_offers, :through=>:auctions
  has_many :avant_offers, :through=>:auctions
  has_one :survey, :dependent=>:destroy
  has_many :funds_withdrawals, :dependent=>:restrict
  has_one :withdrawal_request, :dependent => :destroy
  has_one :user_setting, :dependent => :destroy
  has_many :referred_visits, :dependent => :destroy
  belongs_to :referred_visit
  has_many :user_agent_logs
  has_many :scores, :class_name=>'UserScore', :dependent=>:destroy, :order=>'user_scores.created_at DESC, user_scores.id DESC'
  has_many :transactions, :class_name=>'UserTransaction', :dependent=>:delete_all, :order=>'user_transactions.created_at, user_transactions.id ASC'
  has_many :search_intents, :class_name => 'Search::Intent', :dependent => :destroy
  has_many :intent_outcomes, :class_name => 'Search::IntentOutcome', :through => :search_intents
  has_many :search_box_messages, :class_name => 'Search::BoxMessage', :dependent => :destroy
  has_many :sales_groups, :dependent => :destroy
  has_many :favorite_advertisers, :dependent => :destroy
  has_many :mcb_updates, :dependent=>:destroy
  has_many :sms_alerts, :dependent => :destroy
  has_many :user_service_providers, :dependent => :destroy

  accepts_nested_attributes_for :auctions

  SEX = %w[male female]
  AGE_RANGE = ["18-24", "24-30", "30-36", "36-42", "42-48", "48-55", "55-65", "65-75", "75_or_more"]
  EDUCATION = ["high_school", "bachelors", "masters", "ph.d.", "other"]
  INCOME_RANGE = ["0-5k","5k-20k/year","20k-40k/year","40k-60k/year","60k-80k/year","80k-100k/year", "100k-125k/year","125k-150k/year","150k-200k/year","200k-500k/year", "500k/year_or_more"]
  MARITAL_STATUS = ["single", "married", "divorced", "widowed"]
  FAMILY_SIZE = (1..6).to_a.collect{|x| x.to_s} + ["7 and Up"]

  OCCUPATION = ["Administrative",
  "Advertising",
  "Architecture",
  "Artist/Actor/Creative/Performer",
  "Aviation/Airlines",
  "Banking/Financial",
  "Bio-Pharmaceutical",
  "Bookkeeper",
  "Builder",
  "Business",
  "Celebrity",
  "Chef",
  "Clerical",
  "Computer Related (hardware)",
  "Computer Related (software)",
  "Computer Related (IT)",
  "Consulting",
  "Craftsman/Construction",
  "Customer Support",
  "Designer",
  "Doctor",
  "Educator/Academic",
  "Engineering/Architecture",
  "Entertainment",
  "Environmental",
  "Executive/Senior Management",
  "Farmer",
  "Finance",
  "Flight Attendant",
  "Food Services",
  "Government",
  "Homemaker",
  "Household",
  "Human Resources",
  "Industrial",
  "Insurance",
  "Lawyer",
  "Legal Professions",
  "Medical/Healthcare",
  "Management",
  "Manufacturing/Operations",
  "Marine",
  "Marketing",
  "Media",
  "Medical/Healthcare",
  "Military",
  "Musician",
  "Nurse",
  "Political",
  "Professor",
  "Public Relations",
  "Public Sector",
  "Publishing",
  "Real Estate",
  "Recreation",
  "Research/Scientist",
  "Retail",
  "Retired",
  "Sales",
  "Secretary",
  "Self Employed",
  "Service Industry",
  "Social Science",
  "Social Services",
  "Sports",
  "Student",
  "Technical",
  "Technician",
  "Teaching",
  "Telecommunications",
  "Transportation/Logistics",
  "Travel/Hospitality/Tourism",
  "Unemployed",
  "Other"]

  validates :email, :presence => true
  validates :password, :presence => true, :unless=>Proc.new{dont_require_password}
  validates :password, :confirmation => true, :unless=>Proc.new{dont_require_password_confirmation}
  validates :first_name, :presence => true, :length => { :maximum => 50 }
  validates :last_name, :presence => true, :length => { :maximum => 50 }
  validates :zip_code, :presence => true, :length => { :maximum => 50 }, :format => { :with => /^\d{5}?$/i }
  validates :state_abbreviation, :inclusion => STATE_ABBREVIATIONS, :allow_blank=>true
  validates :terms, :acceptance => true
  validates :referred_visit_id, :uniqueness=>:true, :allow_blank=>true

  validates_uniqueness_of :sales_name, :allow_nil => true
  validates_format_of :sales_name, :with => /^\w+$/, :allow_nil => true
  #validates :sex, :presence => true, :inclusion => SEX
  #validates :age_range, :presence => true, :inclusion => AGE_RANGE
  #validates :education, :presence => true, :inclusion => EDUCATION
  #validates :occupation, :presence => true, :inclusion => OCCUPATION
  #validates :income_range, :presence => true, :inclusion => INCOME_RANGE
  #validates :marital_status, :presence => true, :inclusion => MARITAL_STATUS
  #validates :family_size, :presence => true, :inclusion => FAMILY_SIZE
  #validates :home_owner, :inclusion => { :in => [true, false] }

  validates :facebook_uid, :uniqueness => true
  validates :twitter_uid, :uniqueness => true
  validates :google_uid, :uniqueness => true

  before_validation(:on => :create) do
    if social_registration?
      self.password = Devise.friendly_token[0,20]
      self.password_confirmation = self.password
    end
  end

  after_create do
    UserScore.after_user_create self
  end

  after_save do
    UserScore.after_user_save self
  end

  after_update do
    if email_changed? && !@unconfirmation_triggered
      @unconfirmation_triggered = true
      update_attribute :confirmed_at, nil
      send_confirmation_instructions
    end
  end

  scope :search, lambda {|s|
    unless s.blank?
      where_str = " users.first_name LIKE ?"
      where_str += " OR users.last_name LIKE ?"
      where_str += " OR users.email LIKE ?"
      where_params = [where_str]
      3.times {where_params << "%#{s}%"}
      {:conditions => where_params}
    else
      {}
    end
  }

  #needed for tests
  def terms
  end

  def score
    read_attribute(:score).nil? ? scores.last.score_value : read_attribute(:score)
  end

  # overwritten devise methods: added blocking by admin functionality
  def active_for_authentication?
    super && !self.blocked
  end

  def inactive_message
    !self.blocked ? super : :blocked
  end

  def calculated_balance
    result = 0
    result += auctions.where(:status => "accepted").sum('user_earnings')
    result += referred_visits.sum('earnings')
    result -= funds_withdrawals.where(:success => true).sum('amount')
  end

  def balance
    last_transaction = transactions.last
    last_transaction.nil? ? 0 : last_transaction.resulting_balance
  end

  def old_balance
    read_attribute(:balance)
  end

  def earnings
    last_transaction = transactions.where(:transactable_type=>'Auction').last
    last_transaction.nil? ? 0 : last_transaction.total_amount
  end

  def earnings_with_unconfirmed
    earnings + unconfirmed_earnings
  end

  def total_balance
    balance + unconfirmed_earnings
  end

  def unconfirmed_earnings
    search_intents.select('SUM(user_money) as user_money').joins(:merchants).where('search_merchants.active' => true).where(:has_active_service_merchants => true).where('status != "released"').first.user_money || 0
    #auctions.where(:status => ["unconfirmed", "confirmed"]).sum('user_earnings')
  end

  def need_release?
     Search::IntentOutcome.joins(:intent).where('user_id = ?', id).count > 0
  end

  def worth_per_auction
    total_earnings = 0
    auctions.where(:status=>["confirmed","accepted"]).includes(:winning_bids).each { |a| total_earnings += a.total_earnings }
    count = auctions.where('status <> "active"').count
    count == 0 ? 0 : (total_earnings.to_f / count)
  end

  def social_registration?
    !(facebook_uid.blank? && twitter_uid.blank? && google_uid.blank?)
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    self.find_for_oauth(:facebook, access_token)
  end
  def self.find_for_google_oauth(access_token, signed_in_resource=nil)
    self.find_for_oauth(:google, access_token)
  end

  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    self.find_for_oauth(:twitter, access_token)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if basic_data = session["devise.twitter_data"]

        user.twitter_uid = basic_data.uid
        user.twitter_token = basic_data['credentials']['token']
        user.twitter_secret = basic_data['credentials']['secret']

      elsif basic_data = session["devise.facebook_data"]

        user.facebook_uid = basic_data.uid
        user.facebook_token = basic_data["credentials"]["token"]

        if data = basic_data["extra"]["raw_info"]

          user.email = data["email"] if data["email"] && user.email.blank?
          user.first_name = data["first_name"] if data["first_name"] && user.first_name.blank?
          user.last_name = data["last_name"] if data["last_name"] && user.last_name.blank?
          user.sex = data["gender"] if data["gender"] && user.sex.blank?
          user.city = data["location"]["name"] if (data["location"] && data["location"]["name"]) && user.city.blank?
        end

      elsif basic_data = session["devise.google_data"]

        user.google_uid = basic_data.uid
        user.google_token = basic_data["credentials"]["token"]

        if data = basic_data["info"]
          user.email = data["email"] if data["email"] && user.email.blank?
          user.first_name = data["first_name"] if data["first_name"] && user.first_name.blank?
          user.last_name = data["last_name"] if data["last_name"] && user.last_name.blank?
        end
      end
    end
  end

  def answered_questions_count
    return 0 if survey.nil?
    survey.answered_count
  end

  def unanswered_questions_count
    return Survey.questions_count if survey.nil?
    survey.unanswered_count
  end

  def full_name
    "#{first_name} #{last_name}"
  end


  # settings
  def initiated_auction_mail?
    user_setting.nil? ? false : user_setting.initiated_auction_mail
  end

  def ended_auction_mail?
    user_setting.nil? ? true : user_setting.ended_auction_mail
  end

  def bid_mail?
    user_setting.nil? ? false : user_setting.bid_mail
  end

  def post_to_social?
    return false if twitter_uid.blank? && facebook_uid.blank?
    user_setting.nil? || user_setting.post_to_social.nil? ? true : user_setting.post_to_social
  end

  def post_search_ended_to_facebook user_earnings
    return unless post_to_social?
    return if facebook_uid.blank? || facebook_token.blank?
    begin
      user = FbGraph::User.new(facebook_uid, :access_token => facebook_token)
      user.feed!(
          :message => "I just got a great deal and additionally earned $#{user_earnings} on MuddleMe.com!",
          :link => 'http://muddleme.com',
          :name => 'MuddleMe',
          :description => 'MuddleMe'
      )
    rescue Exception => e
      return false
    end
  end

  def post_search_ended_to_twitter user_earnings
    return unless post_to_social?
    return if twitter_uid.blank? || twitter_token.blank? || twitter_secret.blank?
    begin
      client = Twitter::Client.new(
          :oauth_token => twitter_token,
          :oauth_token_secret => twitter_secret
      )
      client.update("I just got a great deal and additionally earned $#{user_earnings} on MuddleMe.com!")
    rescue Exception => e
      return false
    end
  end

  def to_api_json
    attrs = [
      :id, :email, :facebook_uid, :twitter_uid, :google_uid, :first_name, :last_name, :address, :city, :zip_code,
      :phone, :sex, :age_range, :balance, :total_balance, :confirmed_at, :score
    ]
    result = attrs.inject({}) {|result, attr| result[attr] = send(attr.to_s); result}
    result[:pending_outcome] = unconfirmed_earnings
    result
  end

  private
  def self.find_for_oauth(provider, access_token)
    user = User.where(:"#{provider}_uid"=>access_token.uid).first
    if user
      user.update_attribute(:"#{provider}_token", access_token['credentials']['token'])
      user.update_attribute(:"#{provider}_secret", access_token['credentials']['secret']) unless access_token['credentials']['secret'].blank?
      #TODO ?? are we updating other social attributes that might have changed??
      user
    else
      ## Create a user with a stub password.
      # User.create!(:email => data.email, :password => Devise.friendly_token[0,20])
      nil
    end
  end
end
