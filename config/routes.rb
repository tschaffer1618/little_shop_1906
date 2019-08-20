Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :carts, only: [:create]
  get "/merchants", to: "merchants#index"
  get "/merchants/new", to: "merchants#new"
  get "/merchants/:id", to: "merchants#show"
  post "/merchants", to: "merchants#create"
  get "/merchants/:id/edit", to: "merchants#edit"
  patch "/merchants/:id", to: "merchants#update"
  delete "/merchants/:id", to: "merchants#destroy"

  get "/items", to: "items#index"
  get "/items/:id", to: "items#show"
  get "/items/:id/edit", to: "items#edit"
  get "/items/:id/reviews/new-review", to: "reviews#new"
  get "/items/:item_id/reviews/:review_id/edit-review", to: "reviews#edit"
  get "/items/:item_id/reviews/:review_id/delete", to: "reviews#delete"
  post "/items/:id/", to: "reviews#create", as: :new_review
  patch "/items/:item_id/reviews/:review_id", to: "reviews#update", as: :update_review
  patch "/items/:id", to: "items#update"
  get "/merchants/:merchant_id/items", to: "items#index"
  get "/merchants/:merchant_id/items/new", to: "items#new"
  post "/merchants/:merchant_id/items", to: "items#create"
  delete "/items/:id", to: "items#destroy"
  patch '/items/:id/buy', to: 'items#buy_item', as: :update_purchased_item

  #cart
  get '/cart', to: "cart#index"
end
