# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  require 'net/http'
  require 'uri'

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super
    resource.update(password: params[:password], password_confirmation: params[:password_confirmation], member_id: SecureRandom.alphanumeric(6))
    post_gmo_with_create_member(resource)
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def post_gmo_with_create_member(user)
    uri = URI.parse('https://pt01.mul-pay.jp/payment/SaveMember.idPass')
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      'SiteID' => ENV['SITE_ID'],
      'SitePass' => ENV['SITE_PASS'],
      'MemberID' => user.member_id
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code == '200'
      logger.info('GMO created member!(^ ^)!')
    else
      logger.info('GMO error!!!')
    end
  end
end
