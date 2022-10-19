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

  def find_all
    matching_merchants = Merchant.search_for_all(params[:name])
    render json: MerchantSerializer.new(matching_merchants)
  end

  def find
    if params[:name].present?
      matching_merchant = Merchant.find_matching_merchant(params[:name])
      if matching_merchant.nil?
        render json: {data: {}} 
      else
       render json: MerchantSerializer.new(matching_merchant)
      end
    else
      render json: { error: 'You must enter a query param' }, status: 400
    end
  end

end