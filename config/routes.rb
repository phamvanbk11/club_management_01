Rails.application.routes.draw do
  resources :tags
  root "static_pages#index"
  mount ActionCable.server => "/cable"

  mount Ckeditor::Engine => "/ckeditor"

  delete "join_event" => "user_events#destroy"
  get "other-clubs" => "clubs#index"

  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  post "/hook", to: "wsm_hooks#update"

  devise_for :users, controllers: {registrations: "registrations",
    sessions: "authentications", passwords: "passwords",
    omniauth_callbacks: "omniauth_callbacks"}
  devise_for :admin, controllers: {sessions: "admin/sessions"}

  # devise_scope :admin do
  #   get "/admin/sign_in" => "admin/sessions#new", as: :new_admin_sessions
  #   delete "/admin/sign_out" => "admin/sessions#destroy", as: :destroy_admin_sessions
  # end

  namespace :admin do
    get "/" => "static_pages#index"
    resources :users
    resources :organizations do
      resources :user_organizations
      resources :user_clubs
      resources :clubs
    end
    resources :feed_backs, only: :index
    resources :organization_requests
    resources :import_user_organizations
  end

  namespace :club_manager do
    resources :import_user_clubs, only: :create
    resources :clubs do
      resources :statistic_reports
      resources :club_budgets, only: [:destroy, :create]
      resources :user_clubs
    end
    resources :money_support_clubs, only: %i(index)
    resources :evaluates, only: [:index, :show]
    resources :export_history_budgets
    resources :club_export_members
  end

  resources :users do
    resources :club_requests, expect: [:show, :destroy]
    resources :organization_requests, only: [:new, :create, :index]
    resources :other_clubs, only: :index
    resources :feed_backs, only: [:new, :create]
    resources :user_organizations, except: [:new, :update]
  end

  resources :clubs, only: [:show, :index, :edit] do
    resources :events do
      resources :donates
      resources :set_user_donates
      resources :user_events, only: [:create, :destroy]
    end
    resources :albums do
      resources :images
      resources :videos, only: %i(create destroy update)
      post "/videos/upload", to: "videos#upload"
    end
    resources :sponsors
    resources :budgets
    resources :event_notifications, except: [:index]
    resources :evaluates do
      get :quick_new, on: :collection
    end
  end

  resources :invite_join_clubs, only: :create
  resources :messages
  resources :user_events, only: :create
  resources :ratings, only: :create
  resources :organizations do
    resources :club_types, except: %(show new)
    resources :clubs, except: %i(destroy edit)
    resources :rules, except: :new
  end
  resources :time_line_homes
  resources :time_line_homes
  resources :my_clubs
  resources :comments
  resources :set_language, only: :update
  resources :reason_leaves, only: [:index, :show, :create]
  resources :activities, only: :create
  resources :user_clubs
  resources :user_organizations, only: [:create, :destroy]
  resources :notifications
  resources :user_request_clubs
  resources :set_user_organizations
  resources :user_request_organizations
  resources :club_request_organizations, only: %i(index edit update)
  resources :set_image_clubs
  resources :set_logo_clubs
  resources :set_active_clubs, only: :update
  resources :statistic_reports, except: %i(new destroy create)
  resources :warning_reports, except: %i(new destroy)
  resources :report_categories, except: %i(show new)
  resources :organization_events, only: :index
  resources :organization_settings, only: %i(index update)
  resources :set_static_reports, only: :index
  resources :budgets, only: :index
  resources :posts, except: :new do
    resources :post_galleries, only: :index
  end
  resources :set_sponsor_events, except: %i(new destroy)
  resources :export_reports, only: :index
  resources :set_action_reports, only: :update
  resources :export_report_members, only: :index
  resources :money_supports, only: :create
  resources :range_supports
  resources :setting_clubs, only: %i(edit update show)
  resources :frequencies, except: :show
end
