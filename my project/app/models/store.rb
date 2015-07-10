class Store < ActiveRecord::Base
  belongs_to :storable, :polymorphic => true
  acts_as_mappable


  def self.import_stores_from_csv(file, advertiser)
    first = true
    count = 0
    FasterCSV.foreach(file, :headers => false) do |row|
      if first
        first = false
        next
      end

      store = advertiser.stores.create({
        :name => row[0],
        :address => row[1],
        :lat => (row[2].blank?) ? nil : row[2].split(",").first,
        :lng => (row[2].blank?) ? nil : row[2].split(",").last
        })
        count +=1 if store.persisted?
      end
      count
    end




end
