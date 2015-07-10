class FixTransfersDates < ActiveRecord::Migration
  class VendorTransaction < ActiveRecord::Base
    belongs_to :transactable, :polymorphic => true
  end
  class UserTransaction < ActiveRecord::Base
    belongs_to :transactable, :polymorphic => true
  end
  class MuddlemeTransaction < ActiveRecord::Base
    belongs_to :transactable, :polymorphic => true
  end

  def up
    VendorTransaction.includes(:transactable).each do |transaction|
      VendorTransaction.update_all({
        :created_at=>transaction.transactable.updated_at,
        :updated_at=>transaction.transactable.updated_at
        }, {:id=>transaction.id})
    end

    UserTransaction.includes(:transactable).each do |transaction|
      UserTransaction.update_all({
        :created_at=>transaction.transactable.updated_at,
        :updated_at=>transaction.transactable.updated_at
        }, {:id=>transaction.id})
    end
    
    MuddlemeTransaction.includes(:transactable).each do |transaction|
      MuddlemeTransaction.update_all({
        :created_at=>transaction.transactable.updated_at,
        :updated_at=>transaction.transactable.updated_at
        }, {:id=>transaction.id})
    end
  end

  def down
  end
end
