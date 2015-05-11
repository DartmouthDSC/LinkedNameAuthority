class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # add email?
  validates :uid, :netid, :username, :provider, :name, presence: true
  validates :uid, :netid, :username, uniqueness: true

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
    user = User.find_or_initialize_by(  provider: auth.provider,
                                        uid: auth.extra.uid,
                                        netid: auth.extra.netid,
                                        username: auth.extra.user )
    user.update(realm: auth.uid.split(/@/)[1].downcase,
                name: auth.info.name,
                affil: auth.extra.affil,
                email: auth.extra.user.gsub(/ /, ".").gsub(/\.+/, ".") )
    user
  end

end
