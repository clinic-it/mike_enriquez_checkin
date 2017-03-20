Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
  resources :dashboards

  delete 'checkins' => 'checkins#destroy'
end
