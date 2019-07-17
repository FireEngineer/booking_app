Rails.application.routes.draw do
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
  scope :auth do
    devise_for :users
  end

  resources :user do
    get "tasks_index", to: "configs#tasks_index"
    get "setting", to: "configs#setting"
    patch "update", to: "configs#update"
    resources :tasks
    get "task/:id/complete", to: "tasks#complete", as: :task_complete
    get "task/:id/cancel", to: "tasks#cancel", as: :task_cancel
  end

end
