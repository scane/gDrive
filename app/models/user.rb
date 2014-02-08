class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  #Class Methods
  def self.find_for_google_oauth2(auth)
    u_email = auth.info.email
    user = where(:email => u_email).first
    if user.nil?
      create(:provider => auth.provider, :uid => auth.uid, :email => u_email, :password => u_email, :access_token => auth.credentials.token )
    else
      user
    end
  end
end
