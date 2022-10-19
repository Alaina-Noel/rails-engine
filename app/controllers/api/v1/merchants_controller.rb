class Api::V1::MerchantsController < ApplicationController  
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    if Merchant.exists?(params[:id])
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    else
      render json: { error: 'No merchant found' }, status: 404
    end 
  end

  def find_all
    matching_merchants = Merchant.search_for_all(params[:name])
    render json: MerchantSerializer.new(matching_merchants)
  end
end