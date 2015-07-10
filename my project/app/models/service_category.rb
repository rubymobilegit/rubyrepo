class ServiceCategory < ActiveRecord::Base
  has_many :auctions, :dependent=>:restrict
  has_and_belongs_to_many :vendors
  has_and_belongs_to_many :campaigns
  
  validates :name, :presence=>true
end
