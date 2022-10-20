class Api::V1::MerchantsController < ApplicationController  
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    if Merchant.exists?(params[:id]) #Could assign params[:id] to a variable.
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    else
      render json: { error: 'No merchant found' }, status: 404
    end 
  end
end