Rails.application.routes.draw do
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :warehouses do
    member do
      post :transition
      post :approve_sla
    end
    resources :credit_usage_logs, only: [:create]
    resource :ai_insights, only: [:show] do
      post :predict, on: :collection
    end
  end

  resources :departments, only: [:index, :show]
  resources :cost_alerts, only: [:index, :update]
end
