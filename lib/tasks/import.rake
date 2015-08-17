namespace :import do

  desc "Import faculty from Oracle."
  task oracle_faculty: :environment do
    Oracle::Faculty.find_each do |person|
      begin
        ImportController.into_lna(person.to_hash)
      rescue Exception => fault
        puts("Oracle/Faculty error: #{fault.message}")
      end
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
