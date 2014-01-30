Scheduler::Application.routes.draw do
  namespace :api do
    resources :jobs do
      collection do
        get :scheduled
        get :accepted
        get :processing
        get :on_hold
        get :success
        get :completed
        get :failed
        delete :purge
      end
      
      member do
        post :retry
      end

      member do
        resources :state_changes
        resources :notifications
      end
    end

    match '/schedule' => 'scheduler#schedule'
    
    resources :presets
    
    resources :hosts
    
    match '/statistics' => 'statistics#show'

    resources :uploads
  end

  resources :jobs
  
  resources :presets, :hosts

  resources :uploads

  match '/uploads/reconstruct', to: 'uploads#reconstruct', via: :post
  match '/uploads/deleteAll', to: 'uploads#deleteAll', via: :post #This should be removed once new process is in place
  
  root :to => 'dashboard#show'
end
