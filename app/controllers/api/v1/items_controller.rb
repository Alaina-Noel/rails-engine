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
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item)
    else
      render status: 404
    end
  end

  def destroy 
    invoice_items = InvoiceItem.where(item_id: params[:id])
    invoice_ids = invoice_items.pluck(:invoice_id)
    invoice_items.delete_all
    render json: Item.delete(params[:id]), status: 204
    Invoice.delete_empty_invoices(invoice_ids)
  end

  def find
    if params[:name].present?
       matching_item = Item.find_matching_item(params[:name])
      if matching_item.nil?
        render json: {data: {}} 
      else
       render json: ItemSerializer.new(Item.find_matching_item(params[:name]))
      end
    elsif !params[:name].nil?
      render json: { error: "Query params can't be empty" }, status: 400
    else
      render json: { error: "Query params can't be missing" }, status: 400
    end
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end