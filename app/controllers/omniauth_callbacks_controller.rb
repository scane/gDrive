class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.find_for_google_oauth2(auth)
    #client = OAuth2::Client.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'])
    #puts request.env['omniauth.auth']
    if @user.persisted?
      current_time = Time.now
      credentials = auth.credentials
      @user.update_attributes(:access_token => credentials.token, :refresh_token => credentials.refresh_token, :access_token_expires_at => current_time + (credentials.expires_at - current_time.to_i) )
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      #session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_path
    end
    #token = OAuth2::AccessToken.new(client, request.env['omniauth.auth']['credentials']['token'])
    #response = token.get('https://www.googleapis.com/drive/v2/files')
    #JSON.parse(response.body)
  end
end
