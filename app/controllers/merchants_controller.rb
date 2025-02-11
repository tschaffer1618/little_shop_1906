class MerchantsController < ApplicationController

  def index
    @merchants = Merchant.all
  end

  def show
    if Merchant.where(id: params[:id]).empty?
      flash[:no_merchant] = "This merchant doesn't exist"
      redirect_to "/merchants"
    else
      @merchant = Merchant.find(params[:id])
      @top_item_ids = @merchant.top_three_item_ids
    end
  end

  def new
  end

  def create
    merchant = Merchant.create(merchant_params)
    if merchant.save
      flash[:success] = "Your merchant has been created"
      redirect_to "/merchants"
    else
      flash[:error] = merchant.errors.full_messages.to_sentence
      redirect_to "/merchants/new"
    end
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_params)
    if merchant.save
      flash[:success] = "Your merchant has been updated"
      redirect_to "/merchants/#{merchant.id}"
    else
      flash[:error] = merchant.errors.full_messages.to_sentence
      redirect_to "/merchants/#{merchant.id}/edit"
    end
  end

  def destroy
    merchant = Merchant.find(params[:id])
    if merchant.has_items_ordered
      flash[:no_delete] = "We won't delete merchants with active orders pending"
      redirect_to "/merchants/#{merchant.id}"
    else
      Review.where(item_id: Item.where(merchant_id: params[:id])).destroy_all
      Item.delete(Item.where(merchant_id: params[:id]))
      Merchant.destroy(params[:id])
      redirect_to '/merchants'
    end
  end

  private

  def merchant_params
    params.permit(:name,:address,:city,:state,:zip)
  end
end
