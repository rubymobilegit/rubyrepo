class AvantCoupon < ActiveRecord::Base
  belongs_to :advertiser, :foreign_key=>'advertiser_id', :primary_key=>'advertiser_id',
            :class_name=>'AvantAdvertiser', :conditions=>'avant_advertisers.inactive IS NULL or avant_advertisers.inactive=0'

  validates :advertiser_id, :presence=>true
  validates :advertiser, :presence=>true
  validates :header, :presence=>true
  validates :code, :presence=>true

  CODE_REGEXP = /(code|Code|CODE)(: | | "|: ")([a-zA-Z0-9]{4,20})/

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

  def set_attributes_from_response_row row
    self.advertiser_name = row['Merchant_Name']
    self.advertiser_id   = row['Merchant_Id']
    self.ad_id           = row['Ad_Id']
    self.ad_url          = row['Ad_Url']
    self.header          = row['Ad_Title']
    self.code            = row['Coupon_Code']
    self.code            = AvantCoupon.parse_coupon_code(row['Ad_Title'], row['Ad_Content']) if self.code.blank?
    self.description     = row['Ad_Content']
    self.expires_at      = Date.strptime(row['Ad_Expiration_Date'], '%Y-%m-%d') rescue nil
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

  def self.parse_coupon_code(link_name, description)
    ignore_array = %w(must expies expires field Banner found and)
    result = nil

    matches = CODE_REGEXP.match(link_name)
    if matches
      result = matches[3]
    else
      matches = CODE_REGEXP.match(description)
      result = matches[3] if matches
    end

    result = nil if ignore_array.include?(result)
    result
  end

  def self.reload_all_coupons
    inserted_count = 0
    response = Avant.coupons

    AvantCoupon.transaction do
      response.to_a.each do |row|
        # skip if 'no code needed'
        next if (row['Coupon_Code'] && row['Coupon_Code'].downcase) == 'no code needed'
        coupon = self.find_by_ad_id(row['Ad_Id']) || self.new
        saved = coupon.set_attributes_from_response_row(row).save
        inserted_count += 1 if saved
      end
    end
    # delete expired
    AvantCoupon.delete_all('expires_at IS NOT NULL AND expires_at < DATE_SUB(NOW(),INTERVAL 1 DAY)')
    AvantCoupon.delete_all(["created_at < (?) AND expires_at IS NULL", (Date.today - 2.months)])
    inserted_count
    $notify_team.each do |developer|
      ContactMailer.new_coupons_data_notification("Avant", developer).deliver
    end
  end


  def to_api_json
    attrs = [:advertiser_name, :header, :code, :description]
    result = attrs.inject({}) {|result, attr| result[attr] = send(attr.to_s); result}
  end
end
