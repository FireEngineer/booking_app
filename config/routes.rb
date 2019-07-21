Rails.application.routes.draw do
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
  scope :auth do
    devise_for :users
  end

  resources :users do
    get "setting", to: "users#settiing"
    # get "calendar/:id/tasks_index", to: "calendars#tasks_index", as: "task_index"
    # get "calendar/:id/setting", to: "calendars#setting", as: "calendar_setting"
    patch "calendar/:id/update", to: "calendars#update"

    resources :calendars do
      resources :tasks
        get "tasks/:id/complete", to: "tasks#complete", as: :task_complete
        get "tasks/:id/cancel", to: "tasks#cancel", as: :task_cancel
    end
  end


end
