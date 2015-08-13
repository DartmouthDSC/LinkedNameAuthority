namespace :import do

  desc "Import faculty from Oracle."
  task oracle_faculty: :environment do
    Oracle::Faculty.find_each do |person|
      puts("#{person.to_hash}")
####      Lna::Person.create_or_update(person.to_hash)
    end
  end

end
