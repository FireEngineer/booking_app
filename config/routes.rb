Rails.application.routes.draw do
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
  scope :auth do
    devise_for :users
  end

  # public権限
  scope module: :public do
    resources :calendars, param: :calendar_name, only: [] do
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
