require 'rails_helper'

describe "Merchant Edit Page" do
  before(:each) do
    @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
  end

  it 'has a form to update a merchant with prepopulated info' do
    visit "/merchants/#{@bike_shop.id}/edit"

    expect(find_field('Name').value).to eq(@bike_shop.name)
    expect(find_field('Address').value).to eq(@bike_shop.address)
    expect(find_field('City').value).to eq(@bike_shop.city)
    expect(find_field('State').value).to eq(@bike_shop.state)
    expect(find_field('Zip').value.to_i).to eq(@bike_shop.zip)

    fill_in :name, with: ""
    fill_in :address, with: ""
    fill_in :city, with: "Denver"
    fill_in :state, with: "CO"
    fill_in :zip, with: 80204

    click_button "Update Merchant"

    expect(current_path).to eq("/merchants/#{@bike_shop.id}/edit")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Address can't be blank")

    fill_in :name, with: "Brian's Super Cool Bike Shop"
    fill_in :address, with: "1234 New Bike Rd."
    fill_in :city, with: ""
    fill_in :state, with: ""
    fill_in :zip, with: ""

    click_button "Update Merchant"

    expect(page).to have_content("City can't be blank")
    expect(page).to have_content("State can't be blank")
    expect(page).to have_content("Zip is not a number")

    fill_in 'Name', with: "Brian's Super Cool Bike Shop"
    fill_in 'Address', with: "1234 New Bike Rd."
    fill_in 'City', with: "Denver"
    fill_in 'State', with: "CO"
    fill_in 'Zip', with: 80204

    click_button "Update Merchant"

    expect(current_path).to eq("/merchants/#{@bike_shop.id}")
    expect(page).to have_content("Brian's Super Cool Bike Shop")
    expect(page).to have_content("1234 New Bike Rd.\nDenver, CO 80204")
    expect(page).to have_content("Your merchant has been updated")
  end
end
