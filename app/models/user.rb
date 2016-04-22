class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  
  # Connects this user object to Role-management behaviors. 
  include Hydra::RoleManagement::UserRoles

  validates_presence_of :name, :netid
  validates_uniqueness_of :netid # If we support more providers, this will have to be removed.
  validates_uniqueness_of :uid, allow_nil: true

  # Removed default devise modules except for trackable and added the omniauthable module.
  devise :trackable, :omniauthable, omniauth_providers: [:cas]

  # Method added by Blacklight; Blacklight uses #to_s on your user class to get
  # a user-displayable login/identifier for the account.
  def to_s
    name
  end

  def self.from_omniauth(auth)
    # User created or updated based on CAS information provided by Dartmouth Authentication.
    if auth.provider.eql?(:cas)
      user = User.find_by(provider: auth.provider, netid: auth.extra.netid) ||
             User.find_or_initialize_by(netid: auth.extra.netid)

      user.provider = auth.provider
      user.realm    = auth.extra.user.split(/@/)[1].downcase
      user.name     = auth.info.name
      user.affil    = auth.extra.affil
      user.uid      = "#{user.netid}@#{user.realm}"
      user.save
    else
      raise NotImplementedError, 'Currently, only CAS authentication is provided.'
    end
    user
  end

  def netid=(netid)
    super(netid.downcase)
  end

  def editor?
    roles.where(name: 'editor').exists?
  end
end
