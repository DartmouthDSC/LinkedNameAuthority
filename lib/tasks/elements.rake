require 'symplectic/elements/users'

namespace :elements do
  task :test_users do
    users = Symplectic::Elements::Users.get_all(modified_since: DateTime.new(1990, 1, 1))
    users.each do |u|
      puts "User id: #{u.id}   proprietary-id: #{u.proprietary_id}   "
    end
  end

  task :test_publications do
    user = Symplectic::Elements::Users.get(netid: 'd32073a')
    publications = user.first.all_publications
    puts publications.count
    publications.each do |p|
      puts
      pp p.to_hash
      puts
    end
  end
end
