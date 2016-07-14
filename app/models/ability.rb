class Ability
  # Not using Hydra::Ability, because we are not using Blacklight nor are we limiting any of the
  # show actions. We also don't need finer control over what objects can be edited. Any admins
  # or editors can edit all ActiveFedora::Base objects.
  include CanCan::Ability
  
  # Define permissions here.
  def initialize(user)
    # Permissions needed for hydra-role-management. Admins cannot create, update or destroy roles.
    if user.admin?
      can [:show, :add_user, :remove_user, :index, :edit], Role
    end

    # Permission for editors to make changes to fedora objects.
    if user.editor?
      can :update, ActiveFedora::Base
      can :create, [Lna::Membership, Lna::Collection::FreeToRead, Lna::Collection::LicenseReference, Lna::Account]
    end

    if user.creator?
      can [:create, :update], ActiveFedora::Base
    end

    if user.admin?
      can [:create, :update, :destroy], ActiveFedora::Base
    end
  end
end
