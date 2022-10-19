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
     render json: MerchantSerializer.new(matching_merchants)
  end

  def find
    require 'pry' ; binding.pry
    if params[:name].present?
      matching_merchant = Merchant.find_matching_merchant(params[:name])
      if matching_merchant.nil?
        render json: {data: {}} 
      else
       render json: ItemSerializer.new(matching_merchant)
      end
    else
      render json: { error: 'You must enter a query param' }, status: 404
    end
  end
end