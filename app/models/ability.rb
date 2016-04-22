class Ability
  include Hydra::Ability
  
  # Define any customized permissions here.
  def custom_permissions
    # Permissions needed for hydra-role-management.
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end

    if current_user.editor? || current_user.admin?
      # can [:create, :update, :destroy], [ Lna::Person, Lna::Account, Lna::Membership,
      #                                     Lna::Collection::Document, Lna::Organization,
      #                                     Lna::Organization::Historic,
      #                                     Lna::Organization::ChangeEvent,
      #                                     Lna::Collection::FreeToRead,
      #                                     Lna::Collection::LicenseReference ]

      can [:create, :update, :destroy], ActiveFedora::Base
#      can [:create, :update, :destroy], Lna::Membership
    end
    
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end
