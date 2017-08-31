Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
  resources :users, :only => [:show]

  get 'summary' => 'summary#show'
  get 'summary_checkin' => 'summary#summary_checkin'
  delete 'checkins' => 'checkins#destroy'

  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'
  get 'dashboard' => 'dashboards#index'

  get 'toggle_user_active' => 'users#toggle_active'

  scope '/api' do
    scope :module => :v1, :defaults => {:format => 'json'} do
      resources :projects, :only => [:index, :show]
      resources :users, :only => [:index, :show]
      resources :stories, :only => [:index]
    end
  end
end
