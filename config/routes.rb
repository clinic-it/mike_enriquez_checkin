Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
  resources :dashboards
  resources :users, :only => [:show]

  delete 'checkins' => 'checkins#destroy'
  post 'csv_checkin' => 'checkins#csv_checkin'
  
end
