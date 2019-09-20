Rails.application.routes.draw do
  root :to => 'tops#top'
# ================================================================================================================-
  # googleカレンダー認証
  get 'google_auth/callback'
  get 'google_auth/redirect'
  get 'google_auth/ident_form'
  patch 'google_auth/identifier'
# ================================================================================================================-
  # devise
  devise_for :admins, controllers: {
    sessions:      'admins/sessions',
    passwords:     'admins/passwords',
    registrations: 'admins/registrations'
  }
  scope :auth do
    devise_for :users, controllers: {
      sessions:      'users/sessions',
      passwords:     'users/passwords',
      registrations: 'users/registrations'
    }
  end
  # rootページ用ルーティング
  # devise_scope :user do
  #   root :to => 'devise/sessions#new'
  # end
# ================================================================================================================-
  # admin権限
  scope module: :admin do
    get "admins/:id/dash_board", to: "dash_boards#top", as: :dash_board_top
    resources :admins do

    end
  end
# ================================================================================================================-
  # public権限
  scope module: :public do
    get "task_create", to: "tasks#task_create", as: :task_create
    get "task_create_without_line", to: "tasks#task_create_without_line", as: :task_create_without_line
    resources :calendars, only: [] do
      resources :tasks, except: [:show]
        get "tasks/:id/complete", to: "tasks#complete", as: :task_complete
        get "tasks/:id/cancel", to: "tasks#cancel", as: :task_cancel
        post "tasks/redirect_register_line", to: "tasks#redirect_register_line", as: :redirect_line
        get "tasks/:id/cancel_complete", to: "tasks#cancel_complete", as: :task_cancel_complete
    end
    # カレンダーが公開してない場合のページ
    get "not_released_page", to: "templetes#not_released_page"
  end
# ================================================================================================================-
  # user権限
  scope module: :user do
    resources :users do
      patch "calendar/:id/update", to: "calendars#update"
      patch "calendar/:id/update_is_released", to: "calendars#update_is_released", as: "calendar_update_is_released"
      resources :calendars do
        get "dashboard", to: "top#dashboard"
        get "user_tasks/:id/update_by_drop", to: "user_tasks#update_by_drop"
        resources :user_tasks
        resources :task_courses
        resource :calendar_config
        get "staffs/staffs_shifts", to: "staffs#staffs_shifts", as: "staffs_shifts"
        resources :staffs
        resources :staff_rest_times
        get "staff_rest_times/:id/update_by_drop", to: "staff_rest_times#update_by_drop"
      end
      get "calendar/:id/setting", to: "calendars#setting", as: "calendar_setting"
    end
    resources :calendars, only: [] do
      resources :store_members
      get "store_member_task_show/:id", to:"store_members#store_member_task_show", as: "store_member_task_show"
      patch "store_member_task_update/:id", to: "store_members#update_task", as: "member_update_task"
      resources :iregular_holidays
      resources :staffs, only: [] do
        resources :staff_shifts
      end
    end
    # =====userがアカウント登録した時の最初の設定ページ
    get "introductions/new_calendar", to: "introductions#new_calendar"
    post "introductions/create_calendar", to: "introductions#create_calendar"
    get "introductions/new_staff", to: "introductions#new_staff"
    post "introductions/create_staff", to: "introductions#create_staff"
    # =========

  end
# ================================================================================================================-

end
