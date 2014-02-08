require 'net/http'
class GoogleDriveFilesController < ApplicationController
  before_action :authenticate_user!
  def index
    @current_user = current_user
    if @current_user.access_token.nil?
      @files = []
    else
      if @current_user.access_token_expires_at < Time.now
        uri = URI.parse('https://accounts.google.com/o/oauth2/token')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        params = {
            'client_id' => ENV['GOOGLE_CLIENT_ID'],
            'grant_type' => 'refresh_token',
            'client_secret' => ENV['GOOGLE_SECRET'],
            'refresh_token' => @current_user.refresh_token
        }
        response = http.post(uri.path, URI.encode_www_form(params))
        body = JSON.parse(response.body)
        @current_user.update_attributes(:access_token => body['access_token'], :access_token_expires_at => Time.now + body['expires_in'])
      end
      client = OAuth2::Client.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'])
      token = OAuth2::AccessToken.new(client, @current_user.access_token)
      response = token.get('https://www.googleapis.com/drive/v2/files')
      @files = JSON.parse(response.body)['items']
    end
  end
end
