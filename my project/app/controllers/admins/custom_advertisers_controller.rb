class Admins::CustomAdvertisersController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @custom_advertisers = CustomAdvertiser.all
  end

  def new
    @custom_advertiser = CustomAdvertiser.new
  end

  def edit
    @custom_advertiser = CustomAdvertiser.find(params[:id])
  end

  def show
    @custom_advertiser = CustomAdvertiser.find(params[:id])
  end

  def create
    @custom_advertiser = CustomAdvertiser.new(params[:custom_advertiser])
    if @custom_advertiser.save
      flash[:notice] = 'Successfully added.'
    else
      flash[:alert] = @custom_advertiser.errors.full_messages
    end
    redirect_to :action => :index
  end

  def update
    @custom_advertiser = CustomAdvertiser.find(params[:id])
    if @custom_advertiser.update_attributes(params[:custom_advertiser])
      flash[:notice] = 'Successfully Updated.'
    else
      flash[:alert] = @custom_advertiser.errors.full_messages
    end
    redirect_to :action => :show
  end

  def destroy
    @custom_advertiser = CustomAdvertiser.find(params[:id])
    if @custom_advertiser.destroy
      flash[:notice] = 'Successfully deleted the merchant details.'
    else
      flash[:alert] = "Something went wrong please try again."
    end
    redirect_to :action => :index
  end



end
