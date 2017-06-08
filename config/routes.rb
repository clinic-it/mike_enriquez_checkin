Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
  resources :users, :only => [:show]

  get 'summary' => 'summary#show'
  get 'summary_checkin' => 'summary#summary_checkin'
  delete 'checkins' => 'checkins#destroy'
end
