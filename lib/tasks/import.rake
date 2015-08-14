namespace :import do

  desc "Import faculty from Oracle."
  task oracle_faculty: :environment do
    Oracle::Faculty.find_each do |person|
      hash = person.to_hash
      puts("Filtered: #{hash}")
      ####      Lna::Person.create_or_update(hash)####person.to_hash)
      Lna::Person.create(hash)####person.to_hash)
    end
  end

  require 'pry'
  desc "View faculty from Oracle."
  task debug: :environment do
    Oracle::Faculty.find_each do |person|
      binding.pry
      puts(person.to_hash)
    end
  end

end
