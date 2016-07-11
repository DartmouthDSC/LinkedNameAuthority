class Admin::UserRolesController < ApplicationController
  include Hydra::RoleManagement::UserRolesBehavior

  def create
    authorize! :add_user, @role

    params[:user_key] = params[:user_key].downcase
    
    if u = find_or_create_user(params[:user_key])
      u.roles << @role
      u.save!
      redirect_to role_management.role_path(@role)
    else
      redirect_to role_management.role_path(@role), :flash => { :error => "Unable to find the user #{params[:user_key]}" }
    end
  end

  protected

  def find_or_create_user(netid)
    unless user = User.find_by(netid: netid)
      Net::DartmouthDND.start(%w(name affiliation netid)) do |dnd|
        if p = dnd.find(netid, :one)
          user = User.create!(name: p.name, affil: p.affiliation, netid: p.netid,
                              realm: 'dartmouth.edu')
        end
      end
    end
    user
  end
end
