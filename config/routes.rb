Rails.application.routes.draw do

  root 'sessions#new'

  resources :checkins, :only => [:index, :show, :create, :destroy]

  resources :users, :only => [:index, :show, :create, :edit, :update] do
    collection do
      get :toggle_active
    end
  end

  resources :summary, :only => [:index] do
    collection do
      get :summary_checkin
    end
  end

  resources :dashboards, :only => [:index]

  resources :sessions, :only => [:new, :create, :destroy]

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

  scope :api do
    scope :module => :v1, :defaults => {:format => 'json'} do
      resources :projects, :only => [:index, :show]
      resources :users, :only => [:index, :show]
      resources :stories, :only => [:index]
    end
  end
end
