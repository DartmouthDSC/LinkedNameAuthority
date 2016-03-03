require 'symplectic/elements/users'

namespace :elements do
  task :test do
    users = Symplectic::Elements::Users.get_all(modified_since: DateTime.new(1990, 1, 1))
    users.each do |u|
      puts "User id: #{u.id}   proprietary-id: #{u.proprietary_id}   "
#      puts "Publications: #{users.all_publications.count}"
      
    end
  end
end
