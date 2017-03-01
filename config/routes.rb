Rails.application.routes.draw do

  root 'checkins#new'

  resources :checkins
end
