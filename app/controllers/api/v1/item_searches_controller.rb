class Api::V1::ItemSearchesController < ApplicationController

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

end