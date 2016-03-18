namespace :import do

  # TODO: Should be eventually deleted.
  desc "Import faculty from Oracle."
  task oracle_faculty: :environment do
    Load::People.from_hr_faculty_view
  end

  # TODO: Should probably be removed?
  require 'pry'
  desc "View faculty from Oracle."
  task debug: :environment do
    Oracle::Faculty.find_each do |person|
      binding.pry
      puts(person.to_hash)
    end
  end

  desc "Import from all feeds."
  task all: :environment do
    Load::People.from_hr_faculty_view
    Load::Documents.from_elements
  end
end
