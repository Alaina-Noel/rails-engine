require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    merchant = create(:merchant)
    items = create_list(:item, 10)
    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to be(10)

    items[:data].each do |item_data|
      expect(item_data).to have_key(:id)
      expect(item_data[:id]).to be_a(String)
      
      expect(item_data).to have_key(:type)
      expect(item_data[:type]).to be_a(String)
      expect(item_data[:type]).to eq("item")
      
      expect(item_data).to have_key(:attributes)
      expect(item_data[:attributes]).to be_a(Hash)
      expect(item_data[:attributes][:description]).to be_a(String)
      expect(item_data[:attributes][:unit_price]).to be_a(Float)
    end
  end

    it "can get one item by its id" do 
      id = create(:item).id
  
      get "/api/v1/items/#{id}"
  
      item_data = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      expect(item_data[:data]).to have_key(:id)
      expect(item_data[:data][:id]).to eq(id.to_s)
    
      expect(item_data[:data]).to have_key(:type)
      expect(item_data[:data][:type]).to eq("item")
    
      expect(item_data[:data]).to have_key(:attributes)
      expect(item_data[:data][:attributes][:name]).to be_a(String)
    end

  it "can create a new item" do
    merchant = create(:merchant)

    new_item_params = ({
                          name: 'Green Goblin Eyes',
                          description: 'the googliest eyes',
                          unit_price: 333.99,
                          merchant_id: merchant.id
                        })
    headers = {"Content-Type" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: new_item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(response.status).to eq(201)

    expect(created_item.name).to eq(new_item_params[:name])
    expect(created_item.description).to eq(new_item_params[:description])
    expect(created_item.unit_price).to eq(new_item_params[:unit_price])
  end

  describe 'sad path' do
    it "can render a 404 error if the item can not be created because of an invalid datatype" do
      merchant = create(:merchant)
      create(:item)
      new_item_params = ({
                        name: 'Green Goblin Eyes',
                        description: 'the googliest eyes',
                        unit_price: "lots of money",
                        merchant_id: merchant.id
                      })

      most_recent_item = Item.last

      headers = {"Content-Type" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: new_item_params)
      created_item = Item.last

      expect(response.status).to eq(404)
      expect(Item.last).to eq(most_recent_item)
    end

    it "edge case: it can render a 404 error if all attributes are missing" do
      merchant = create(:merchant)
      create(:item)
      most_recent_item = Item.last

      new_item_params = ({
                        name: '',
                        description: '',
                        unit_price: '',
                        merchant_id: ''
                      })
      headers = {"Content-Type" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: new_item_params)

      expect(response.status).to eq(404)
      expect(Item.last).to eq(most_recent_item)
      expect(Item.last.name).to_not eq('')
    end
  end

  it "can update an existing item" do
    id = create(:item).id
    create(:item)
    create(:item)
    create(:item)

    previous_name = Item.last.name
    item_params = { name: "Pink Earrings" }
    headers = {"CONTENT_TYPE" => "application/json"}
    
    put "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)
  
    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("Pink Earrings" )
  end

  describe 'sad path' do 
    it 'can render a 404 error if item is unsuccessfully updated' do
      item = create(:item)
  
      item_params = { name: "" }
      headers = {"CONTENT_TYPE" => "application/json"}
      
      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
      expect(response.status).to eq(404)
      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:error]).to eq('Item unsuccessfully updated' )
      expect(Item.last.name).to_not eq("")
    end
  end

  it "can delete an item" do
    item = create(:item)
  
    expect(Item.count).to eq(1)
    
    delete "/api/v1/items/#{item.id}"
  
    expect(response).to be_successful
    expect(response.status).to eq(204)
    expect(response.body).to eq("")
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  #//TODO delete an item that doesn't exist

  it "can destroy an invoice if this was the only item on the invoice" do
    item1 = create(:item)
    item2 = create(:item)
    item3 = create(:item)

    invoice1 = create(:invoice)
    invoice2 = create(:invoice)
    invoice3 = create(:invoice)
    invoice4 = create(:invoice)

    invoice_item1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 10, unit_price: 88) 
    invoice_item2 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 100, unit_price: 899)  
    invoice_item3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 300, unit_price: 999) 

    invoice_item4 = InvoiceItem.create!(invoice_id: invoice2.id, item_id: item1.id, quantity: 10, unit_price: 88) 
    invoice_item5 = InvoiceItem.create!(invoice_id: invoice2.id, item_id: item2.id, quantity: 10, unit_price: 88) 

    invoice_item6 = InvoiceItem.create!(invoice_id: invoice3.id, item_id: item3.id, quantity: 10, unit_price: 88) #will be empty after we delete item 3

    invoice_item7 = InvoiceItem.create!(invoice_id: invoice4.id, item_id: item3.id, quantity: 10, unit_price: 88)  #will be empty after we delete item 3

    expect{ delete "/api/v1/items/#{item3.id}" }.to change(Invoice, :count).by(-2) #it used to be 4

    expect(response).to be_successful
    expect(response.status).to eq(204)
    expect(response.body).to eq("")
    expect(Invoice.count).to eq(2)
    expect{Invoice.find(item3.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end
  #//TODO same item on the invoice

  it "can return the single merchant associated with an item " do
    item1 = create(:item)
    get "/api/v1/items/#{item1.id}/merchant"

    expect(response).to be_successful

    merchant_info = JSON.parse(response.body, symbolize_names: true)
    expect(merchant_info).to have_key(:data)
    expect(merchant_info[:data][:id]).to eq(item1.merchant_id.to_s)
    expect(merchant_info[:data][:type]).to eq("merchant")
    expect(merchant_info[:data][:attributes][:name]).to be_a(String)
  end

  it "can display a 404 if seraching for a single item & no merchant is not found for that item" do
    get "/api/v1/items/99999/merchant"
    expect(response.status).to eq(404)
  end

  it "can find one item by name which matches a query param" do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item2 = Item.create!(name: "Bracelet", description: "Cool and nice", unit_price: 900, merchant_id: merchant2.id)
    item3 = Item.create!(name: "Jewelery Earrings", description: "Pretty", unit_price: 800, merchant_id: merchant1.id)
    item1 = Item.create!(name: "Earrings", description: "Pretty", unit_price: 888, merchant_id: merchant1.id)
    item4 = Item.create!(name: "Shoes", description: "Nice Shoes", unit_price: 8, merchant_id: merchant1.id)
    item5 = Item.create!(name: "Plates", description: "plates are cool", unit_price: 88888, merchant_id: merchant2.id)

    get "/api/v1/items/find?name=ring"
    expect(response).to be_successful
    item_info = JSON.parse(response.body, symbolize_names: true)
    expect(item_info).to have_key(:data)
    expect(item_info[:data][:id]).to eq(item1.id.to_s)
    expect(item_info[:data][:type]).to eq("item")
    expect(item_info[:data][:attributes][:name]).to be_a(String)
    expect(item_info[:data][:attributes][:name]).to eq(item1.name.to_s)
  end

  it "can display a 200 & null data body if no item matches the a search param" do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item2 = Item.create!(name: "Bracelet", description: "Cool and nice", unit_price: 900, merchant_id: merchant2.id)
    item3 = Item.create!(name: "Jewelery Earrings", description: "Pretty", unit_price: 800, merchant_id: merchant1.id)
    item1 = Item.create!(name: "Earrings", description: "Pretty", unit_price: 888, merchant_id: merchant1.id)
    item4 = Item.create!(name: "Shoes", description: "Nice Shoes", unit_price: 8, merchant_id: merchant1.id)
    item5 = Item.create!(name: "Plates", description: "plates are cool", unit_price: 88888, merchant_id: merchant2.id)

    get "/api/v1/items/find?name=LLL"
    expect(response.status).to eq(200)

    item_info = JSON.parse(response.body, symbolize_names: true)
    expect(item_info).to have_key(:data)
    expect(item_info[:data]).to be_an(Object)
    expect(item_info[:data]).to eq({})
  end

  it "can display a 400 & null data body if user doesn't type a query param" do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item2 = Item.create!(name: "Bracelet", description: "Cool and nice", unit_price: 900, merchant_id: merchant2.id)
    item3 = Item.create!(name: "Jewelery Earrings", description: "Pretty", unit_price: 800, merchant_id: merchant1.id)
    item1 = Item.create!(name: "Earrings", description: "Pretty", unit_price: 888, merchant_id: merchant1.id)
    item4 = Item.create!(name: "Shoes", description: "Nice Shoes", unit_price: 8, merchant_id: merchant1.id)
    item5 = Item.create!(name: "Plates", description: "plates are cool", unit_price: 88888, merchant_id: merchant2.id)

    get "/api/v1/items/find?name="
    expect(response.status).to eq(400)

    item_info = JSON.parse(response.body, symbolize_names: true)
    expect(item_info).to have_key(:error)
    expect(item_info[:error]).to eq("Query params can't be empty")
  end

  it "can display a 400  & an informative error message if user doesn't use a query param category" do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)

    item2 = Item.create!(name: "Bracelet", description: "Cool and nice", unit_price: 900, merchant_id: merchant2.id)
    item3 = Item.create!(name: "Jewelery Earrings", description: "Pretty", unit_price: 800, merchant_id: merchant1.id)
    item1 = Item.create!(name: "Earrings", description: "Pretty", unit_price: 888, merchant_id: merchant1.id)
    item4 = Item.create!(name: "Shoes", description: "Nice Shoes", unit_price: 8, merchant_id: merchant1.id)
    item5 = Item.create!(name: "Plates", description: "plates are cool", unit_price: 88888, merchant_id: merchant2.id)

    get "/api/v1/items/find"
    expect(response.status).to eq(400)

    item_info = JSON.parse(response.body, symbolize_names: true)
    expect(item_info).to have_key(:error)
    expect(item_info[:error]).to eq("Query params can't be missing")
  end
end