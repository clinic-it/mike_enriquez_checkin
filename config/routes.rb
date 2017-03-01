Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins

  delete 'checkins' => 'checkins#destroy'
end
