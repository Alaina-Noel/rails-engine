class Api::V1::Items::MerchantsController < ApplicationController

  def index
    if Item.exists?(params[:item_id])
      merchant = Merchant.find(Item.find(params[:item_id]).merchant_id)
      render json: MerchantSerializer.new(merchant)
    else
      render json: { error: 'No item found' }, status: 404
    end 
  end
end