class Users::FundsWithdrawalsController < ApplicationController
  before_filter :disallow_unconfirmed, :only=>['new','create']

  def index
    @withdrawal = current_user.funds_withdrawals.build(:paypal_email=>current_user.email)
    list_earnings_and_withdrawals(current_user)
  end

  def new
    @withdrawal = current_user.funds_withdrawals.build(:paypal_email=>current_user.email)
  end

  def process_payment
    @withdrawal = current_user.funds_withdrawals.build(params[:funds_withdrawal])
    if @withdrawal.save
      @withdrawal.execute
      redirect_to url_for(:action=>'index'), :notice => "Your withdrawal request is successfull"
    else
      flash[:alert] = 'Withdrawal saving error.'
      unless @withdrawal.errors[:updated_at].blank?
        time_to_wait = view_context.distance_of_time_in_words(FundsWithdrawal::MIN_TIME_BETWEEN_WITHDRAWALS)
        flash[:alert] = "You have to wait at least #{time_to_wait} before withdrawing funds again"
      end
      redirect_to url_for(:action=>'index')
    end
  end

  def create
    redirect_to url_for(:action=>'index'), :alert => "Your can't withdraw money until 21 days after registration." and return if Time.now - 21.days < current_user.created_at
    balance_check = FundsWithdrawal.check_account_balance
    if balance_check[:success]
      if balance_check[:balance].to_i < params[:funds_withdrawal][:amount].to_i
        if current_user.withdrawal_request.blank?
          withdrawal_request = current_user.build_withdrawal_request(params[:funds_withdrawal])
          withdrawal_request.save
          ContactMailer.withdrawal_request_update(current_user).deliver
          redirect_to url_for(:action=>'index'), :notice => "We are notified, your earnings will be transfered shortly."
        else
          redirect_to url_for(:action=>'index'), :alert => "Your earlier request is being processed. Please try again after some time."
        end
      else
        process_payment
      end
    end


#    @withdrawal = current_user.funds_withdrawals.build(params[:funds_withdrawal])
#    if @withdrawal.save
#      #if @withdrawal.execute
#      withdrawal_request = @withdrawal.execute_withdrawal_request
#      if withdrawal_request[:success]
#        redirect_to url_for(:action=>'index'), :notice => "Your withdrawal was successfully saved."
#      else
#        session.delete(:withdrawal_errors) if session.has_key?(:withdrawal_errors)
#        session[:withdrawal_errors] = withdrawal_request[:errors]
#        redirect_to url_for(:action=>'index', :errors => true)
#      end
#    else
#      flash[:alert] = 'Withdrawal saving error.'
#      unless @withdrawal.errors[:updated_at].blank?
#        time_to_wait = view_context.distance_of_time_in_words(FundsWithdrawal::MIN_TIME_BETWEEN_WITHDRAWALS)
#        flash[:alert] = "You have to wait at least #{time_to_wait} before withdrawing funds again"
#      end
#      redirect_to url_for(:action=>'index')
#    end
  end

end
