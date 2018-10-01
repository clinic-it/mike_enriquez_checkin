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

  resources :works, :only => [:index] do
    collection do
      get :pivotal_projects_data
      get :pivotal_project_stories_data
      put :pivotal_update_state
      get :freshbooks_projects_data
      get :freshbooks_tasks_data
      get :freshbooks_time_entries_data
      post :freshbooks_log_hours
      post :freshbooks_delete_logged_hours
    end
  end

  scope '/api' do
    scope :module => :v1, :defaults => {:format => 'json'} do
      resources :projects, :only => [:index, :show]
      resources :users, :only => [:index, :show]
      resources :stories, :only => [:index]
    end
  end
end
