class Api::V1::Merchants::ItemsController < ApplicationController

  def index
    if Merchant.exists?(params[:merchant_id]) && !Merchant.find(params[:merchant_id]).items.empty?
      items = Item.where(merchant_id: Merchant.find(params[:merchant_id]))
      render json: ItemSerializer.new(items)
    else
      render json: { error: 'No item found' }, status: 404
    end 
  end
end