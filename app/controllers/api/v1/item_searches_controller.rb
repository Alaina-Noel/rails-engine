class Api::V1::ItemSearchesController < ApplicationController

  def find
    if params[:name].present?
      matching_item = Item.find_matching_item(params[:name])
      render json: serialize_item(matching_item)
    elsif !params[:name]
      render json: { error: "'name' is a required query parameter" }, status: :bad_request
    else
      render json: { error: "Query params can't be empty" }, status: :bad_request
    end
  end

  private

  def serialize_item(item)
    return {data: {}} if item.nil?
    ItemSerializer.new(item)
  end

end