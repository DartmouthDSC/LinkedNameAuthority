class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  validates :name, :netid, :provider, :realm,  presence: true
  validates :uid, :netid, uniqueness: true

  # Removed default devise modules except for trackable and added the
  # omniauthable module.
  devise :trackable, :omniauthable, :omniauth_providers => [:cas]

  # Method added by Blacklight; Blacklight uses #to_s on your user class to get
  # a user-displayable login/identifier for the account.
  def to_s
    name
  end

  # User created or updated based on CAS information provided by Dartmouth Authentication.
  def self.from_omniauth(auth)
    # If user is already in database update fields, otherwise initialize a new
    # record with the given information.
    user = User.find_or_initialize_by(provider: auth.provider, netid: auth.extra.netid)
    user.realm = auth.uid.split(/@/)[1].downcase
    user.name = auth.info.name
    user.affil = auth.extra.affil
    user.uid = "#{user.netid}@#{user.realm}"
    user.save
    
    user
  end

end
