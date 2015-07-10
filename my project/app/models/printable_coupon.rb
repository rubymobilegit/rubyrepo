class PrintableCoupon < ActiveRecord::Base
  belongs_to :user_coupon
  has_attached_file :coupon_image, :styles => {:medium => "300X300>", :thumb => "100X100>"}
  #validates_attachment_content_type :coupon_image, :content_type => /Aimage\/.*\Z/
end
