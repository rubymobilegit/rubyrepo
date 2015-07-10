class LinkshareCoupon < ActiveRecord::Base
  belongs_to :advertiser, :foreign_key => 'advertiser_id', :primary_key => 'advertiser_id',
             :class_name => 'LinkshareAdvertiser', :conditions => 'linkshare_advertisers.inactive IS NULL or linkshare_advertisers.inactive=0'

  validates :advertiser_id, :presence => true
  validates :advertiser, :presence => true
  validates :header, :presence => true
  validates :code, :presence => true

  def self.import_csv file
    first = true
    count = 0
    FasterCSV.foreach(file, :headers => false) do |row|
      if first
        first = false
        next
      end
      existing_coupon = LinkshareCoupon.find_by_advertiser_id_and_code_and_header(row[1], row[3], row[2])
      if existing_coupon.nil?
        coupon = self.create({
                               :advertiser_name => row[0],
                               :advertiser_id => row[1],
                               :header => row[2],
                               :code => row[3],
                               :description => row[4],
                               :expires_at => row[5],
                               :manually_uploaded => true
                           })
        count +=1 if coupon.persisted?
      end
    end
    count
  end

  def set_attributes_from_response_row(row)
    self.advertiser_name = row['advertisername']
    self.advertiser_id = row['advertiserid']
    self.ad_url = row['clickurl']
    matches = /offerid=\d+\.(\d+)/.match(row['clickurl'])
    self.ad_id = matches.length > 1 ? matches[1] : nil
    self.description = row['offerdescription']
    self.header = row['promotiontypes']['promotiontype'].to_a.join(', ')
    self.code = row['couponcode']
    self.expires_at = Date.strptime(row['offerenddate'], '%Y-%m-%d') rescue nil
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

  def self.reload_all_coupons
    response = Linkshare.coupons
    LinkshareCoupon.transaction do
      response.each do |row|
        matches = /offerid=\d+\.(\d+)/.match(row['clickurl'])
        coupon = matches.length > 1 ? self.find_or_initialize_by_ad_id(matches[1]) : self.new
        coupon.set_attributes_from_response_row(row)
        existing_coupon = LinkshareCoupon.find_by_advertiser_id_and_code_and_header(coupon.advertiser_id, coupon.code, coupon.header)
        coupon.save if existing_coupon.nil?
      end
    end
    # delete expired
    LinkshareCoupon.delete_all('expires_at IS NOT NULL AND expires_at < DATE_SUB(NOW(),INTERVAL 1 DAY)')
    LinkshareCoupon.delete_all(["created_at < (?) AND expires_at IS NULL", (Date.today - 2.months)])
    $notify_team.each do |developer|
      ContactMailer.new_coupons_data_notification("Linkshare", developer).deliver
    end
  end
end
