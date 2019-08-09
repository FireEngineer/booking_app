Rails.application.routes.draw do
# ================================================================================================================-
  # googleカレンダー認証
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
# ================================================================================================================-
  # devise
  scope :auth do
    devise_for :users 
  end
  # rootページ用ルーティング
  devise_scope :user do
    root :to => 'devise/sessions#new'
  end
# ================================================================================================================-
  # public権限
  scope module: :public do
    get "task_create", to: "tasks#task_create", as: :task_create
    resources :calendars, param: :calendar_name, only: [] do
      resources :tasks
        get "tasks/:id/complete", to: "tasks#complete", as: :task_complete
        get "tasks/:id/cancel", to: "tasks#cancel", as: :task_cancel
        post "tasks/redirect_register_line", to: "tasks#redirect_register_line", as: :redirect_line
    end
  end
# ================================================================================================================-
  # user権限
  scope module: :user do
    resources :users do
      get "dashboard", to: "users#dashboard"
      patch "calendar/:id/update", to: "calendars#update"
      resources :calendars, param: :calendar_name do
        resources :user_tasks
        resources :task_courses
        resource :calendar_config
      end
      get "calendar/:id/setting", to: "calendars#setting", as: "calendar_setting"
    end
  end


end
