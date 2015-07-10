class HpAdvertiserImage < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  has_attached_file :hp_image, :styles => { :thumb => "100X100>", :medium => "381X328#", :upload => "48x48>", :iphone=>"268x>", :iphone2x=>"536x>" }
  has_attached_file :hp_logo, :styles => { :thumb => "100X100>", :medium => "100X100#", :upload => "48x48>", :iphone=>"268x>", :iphone2x=>"536x>" }
  validates_attachment_presence :hp_image, :allow_nil => true, :if => :hp_image?
  validates_attachment_content_type :hp_image, :content_type=>BROWSER_SUPPORTED_IMAGE_MIME_TYPES, :allow_blank => true
end
