class Api::V1::ItemsController < ApplicationController  
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    if Item.exists?(params[:id])
    render json: ItemSerializer.new(Item.find(params[:id]))
    else
      render json: { error: 'No item found' }, status: 404
    end
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
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      if item.update(item_params)
        render json: ItemSerializer.new(item)
      else
        render json: { error: 'Item unsuccessfully updated' }, status: 404
      end
    else
      render json: { error: 'No item found' }, status: 404
    end
  end

  def destroy
    if Item.exists?(params[:id])
      invoice_items = InvoiceItem.where(item_id: params[:id])
      invoice_ids = invoice_items.pluck(:invoice_id)
      invoice_items.delete_all
      render json: Item.delete(params[:id]), status: 204
      Invoice.delete_empty_invoices(invoice_ids)
    else
      render json: { error: "That item doesn't exist" }, status: 404
    end
  end

private
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end