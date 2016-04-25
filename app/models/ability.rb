class Ability
  # Not using Hydra::Ability, because we are not using Blacklight nor are we limiting any of the
  # show actions. We also don't need finer control over what objects can be edited. Any admins
  # or editors can edit all ActiveFedora::Base objects.
  include CanCan::Ability
  
  # Define permissions here.
  def initialize(user)
    # Permissions needed for hydra-role-management.
    if user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end

    if user.editor? || user.admin?
      # can [:create, :update, :destroy], [ Lna::Person, Lna::Account, Lna::Membership,
      #                                     Lna::Collection::Document, Lna::Organization,
      #                                     Lna::Organization::Historic,
      #                                     Lna::Organization::ChangeEvent,
      #                                     Lna::Collection::FreeToRead,
      #                                     Lna::Collection::LicenseReference ]

      can [:create, :update, :destroy], ActiveFedora::Base
    end
  end
end
