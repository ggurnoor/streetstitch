Rails.application.routes.draw do
  # Admin authentication
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Devise user authentication
  devise_for :users

  # Homepage
  root "home#index"

  # Static pages
  get "/about", to: "pages#about"
  get "/contact", to: "pages#contact"
  get "/pages/:slug/edit", to: "pages#edit", as: :edit_page
  patch "/pages/:slug", to: "pages#update", as: :page

  # Products and categories
  resources :products
  resources :categories, except: [:show]
  get "categories/:id/products", to: "categories#products", as: :category_products

  # Cart and cart items
  resource :cart, only: [:show]
  resources :cart_items, only: [:create, :update, :destroy]

  # ✅ Place the preview route BEFORE orders
  post 'orders/preview', to: 'orders#preview', as: :preview_order

  # Orders
  resources :orders, only: [:new, :create, :show, :index] do
    post 'stripe_checkout', on: :member
    collection do
      post 'preview'
    end
    post 'stripe_checkout', on: :member

  end


  # Checkout shortcut
  get "/checkout", to: "orders#new", as: :checkout

  # Stripe Payment Handling
  post '/fake_payment_confirmation', to: 'payments#fake_confirm'
  post '/webhooks/stripe/receive', to: 'webhooks/stripe#receive'


  # Health check & PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
