class Api::V1::ItemsController < ApplicationController  
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: 201
    else
      render status: 404
    end
  end

  def update
    render json: Item.update(params[:id], item_params) #if you don't include params[:id] it will find each every item
  end

  def destroy
    render json: Item.delete(params[:id])
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end