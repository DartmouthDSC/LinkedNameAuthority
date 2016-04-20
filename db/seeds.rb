# This file should contain all the record creation needed to seed the database with its
# default values. The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

case Rails.env
when 'development', 'qa'
  admin = Role.create!(name: "admin")
  editor = Role.create!(name: "editor")

  admins = [
    { name: 'Carla M. Galarza', netid: 'd31309k' },
    { name: 'Eric J. Bivona',   netid: 'd28584r' },
    { name: 'John P. Bell',     netid: 'f001m9b' }
  ]

  admins.each do |attrs|
    puts attrs
    User.create!(attrs) do |u|
      u.roles << admin
    end
  end
end
