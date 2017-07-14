Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
  resources :dashboards
  resources :users, :only => [:show]

  get 'summary' => 'summary#show'
  get 'summary_checkin' => 'summary#summary_checkin'
  delete 'checkins' => 'checkins#destroy'
  post 'csv_checkin' => 'checkins#csv_checkin'

end
