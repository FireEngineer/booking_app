Rails.application.routes.draw do
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
  # resources :tasks, path: '/'
  scope :auth do
    devise_for :users
  end

  resources :user do
    resources :tasks
    get "task/:id/complete", to: "tasks#complete", as: :task_complete
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # root "schedules#top"
  
  # get "/form", to: "schedules#form"
  # get "/complete", to: "schedules#complete"
  # get "/fail_page", to: "schedules#fail_page"
  # post "/create_event", to: "schedules#create_event"
  # get "/cancel/:id", to: "schedules#cancel"
  # delete "/cancel/:id", to: "schedules#delete_event", as: :delete_event

end
