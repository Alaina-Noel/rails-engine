class Api::V1::MerchantSearchesController < ApplicationController

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