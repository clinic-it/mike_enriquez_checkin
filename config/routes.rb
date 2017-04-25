Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
  resources :users, :only => [:show]

  delete 'checkins' => 'checkins#destroy'
end
