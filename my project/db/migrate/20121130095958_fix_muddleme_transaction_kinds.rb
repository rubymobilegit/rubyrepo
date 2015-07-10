class FixMuddlemeTransactionKinds < ActiveRecord::Migration
  
  class MuddlemeTransaction < ActiveRecord::Base
  end

  def up
    MuddlemeTransaction.update_all({:kind=>'affiliate_commission_without_user_share_add'}, {:kind=>'cj_commision_without_user_share_add'})
    MuddlemeTransaction.update_all({:kind=>'affiliate_commission_add'}, {:kind=>'cj_commision_add'})
    MuddlemeTransaction.update_all({:kind=>'affiliate_commission_substract_user_share'}, {:kind=>'cj_commision_substract_user_share'})
  end

  def down
  end
end
