class IrCoupon < ActiveRecord::Base
  belongs_to :advertiser, :foreign_key=>'advertiser_id', :primary_key=>'advertiser_id',
            :class_name=>'IrAdvertiser', :conditions=>'ir_advertisers.inactive IS NULL or ir_advertisers.inactive=0'

  validates :advertiser_id, :presence => true
  validates :advertiser, :presence => true
  validates :header, :presence => true
  validates :code, :presence => true
  validates_uniqueness_of :code, :scope => [:advertiser_id, :header], :case_sensitive => false

  CODE_REGEXP = /(code|Code|CODE)(: | | "|: ")([a-zA-Z0-9]{4,20})/

  def self.reload_all_coupons
    inserted_count = 0
    page = 0
    begin
      page += 1
      coupons = IR.coupons page
      unless coupons.blank?
        IrCoupon.transaction do
          coupons.each do |row|
            coupon = self.find_or_initialize_by_ad_id(row['Id'])
            saved = coupon.set_attributes_from_response_row(row).save
            inserted_count += 1 if saved
          end
        end
      end
    end
    IrCoupon.delete_all('expires_at IS NOT NULL AND expires_at < DATE_SUB(NOW(),INTERVAL 1 DAY)')
    IrCoupon.delete_all(["created_at < (?) AND expires_at IS NULL", (Date.today - 2.months)])
    inserted_count
    $notify_team.each do |developer|
      ContactMailer.new_coupons_data_notification("Impact Radius", developer).deliver
    end
  end

  def set_attributes_from_response_row row
    self.advertiser_name = row['CampaignName']
    self.advertiser_id        = row['CampaignId']
    self.ad_id                       = row['Id']
    self.ad_url                     = row['TrackingLink']
    self.header                    = row['LinkText']
    self.code                        = row['PromoCode']
    self.description           = row['LinkText']
    self.start_date             = Date.strptime(row['StartDate'], '%Y-%m-%d') rescue nil
    self.expires_at             = Date.strptime(row['EndDate'], '%Y-%m-%d') rescue nil
    if self.expires_at.blank?
      puts "No Expiry date for :: #{self.advertiser_id.inspect} :: #{self.description.inspect}"
      begin
        format_regex = /\d{2}\/\d{2}/
        format_two_regex =  /\d{2}\/\d{2}-\d{2}\/\d{2}/
        if self.description =~ format_regex
          expiry_date = Date.parse(self.description)
          self.expires_at = expiry_date.to_s rescue nil
        elsif self.description =~ format_two_regex
          self.expires_at =~ Date.parse(self.description.split("-").last) rescue nil
        end
      rescue => e
        puts "#{e.message}::self.description"
      end
    end
    self
  end

  # def self.parse_coupon_code(coupon_code)
  #   ignore_array = ["n/a", "NA", "N/A", "no code needed", "No code required", "None Required", "No coupon code necessary", "none needed", "No Code Necessary", "none require", "No Coupon Coded Needed", "None"]
  #   result = nil
  #
  #   matches = CODE_REGEXP.match(coupon_code)
  #
  #   if matches
  #     result = matches[3]
  #   end
  #
  #   result = nil if ignore_array.include?(result)
  #   result
  # end

  def self.import_csv file
    first = true
    count = 0
    FasterCSV.foreach(file, :headers => false) do |row|
      if first
        first = false
        next
      end

      coupon = self.create({
          :advertiser_name=>row[0],
          :advertiser_id=>row[1],
          :header=>row[2],
          :code=>row[3],
          :description=>row[4],
          :expires_at=> row[5],
          :manually_uploaded => true
        })
      count +=1 if coupon.persisted?
    end
    count
  end
end
