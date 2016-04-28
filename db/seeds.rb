# This file should contain all the record creation needed to seed the database with its
# default values. The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@admin  = Role.find_or_create_by!(name: "admin")
@editor = Role.find_or_create_by!(name: "editor")

def add_admins(admins)
  add_role_to_users(@admin, admins)
end

def add_editors(editors)
  add_role_to_users(@editor, editors)
end

def add_role_to_users(role, users)
  users.each do |attrs|
    User.find_or_create_by!(attrs) do |u|
      u.roles << role
    end
  end
end

add_admins(
  [
    { name: 'Carla M. Galarza', netid: 'd31309k', realm: 'dartmouth.edu' },
    { name: 'Eric J. Bivona',   netid: 'd28584r', realm: 'dartmouth.edu' },
    { name: 'John P. Bell',     netid: 'f001m9b', realm: 'dartmouth.edu' }
  ]
)

if Rails.env == 'production' || Rails.env == 'qa'
  add_admins(
    [
      { name: 'Carole F. Meyers',  netid: 'f001hm3', realm: 'dartmouth.edu' },
      { name: 'Jennifer W. Green', netid: 'f002mr2', realm: 'dartmouth.edu' }
    ]
  )
end



