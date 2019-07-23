Rails.application.routes.draw do
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
  scope :auth do
    devise_for :users
  end

  # public権限
  resources :users, only: [] do
    # get "setting", to: "users#setting"
    # # get "calendar/:id/tasks_index", to: "calendars#tasks_index", as: "task_index"
    # # get "calendar/:id/setting", to: "calendars#setting", as: "calendar_setting"
    # patch "calendar/:id/update", to: "calendars#update"

    resources :calendars, only: [] do
      resources :tasks
        get "tasks/:id/complete", to: "tasks#complete", as: :task_complete
        get "tasks/:id/cancel", to: "tasks#cancel", as: :task_cancel
    end
  end
# ================================================================================================================-
  # user権限
  scope module: :user do
    resources :users do
      get "dashboard", to: "users#dashboard"
      patch "calendar/:id/update", to: "calendars#update"
      resources :calendars do
        resources :user_tasks
      end
      get "calendar/:id/setting", to: "calendars#setting", as: "calendar_setting"
    end
  end


end
