Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Kinde Authentication Routes
  get '/login', to: 'auth#login'
  get '/auth/callback', to: 'auth#callback'
  get '/profile', to: 'auth#profile'
  get '/logout', to: 'auth#logout'
  
  # Test endpoints for KSP (Session Persistence)
  get '/test-ksp', to: 'auth#test_ksp'
  get '/test-session-only', to: 'auth#test_session_only'
  get '/test-persistent', to: 'auth#test_persistent'
  
  # Root path - show welcome page
  root "rails/welcome#index"
end
