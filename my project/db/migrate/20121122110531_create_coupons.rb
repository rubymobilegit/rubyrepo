class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :advertiser_name
      t.string :advertiser_id
      t.string :header
      t.string :code
      t.text :description
      t.date :expires_at

      t.timestamps
    end
  end
end
