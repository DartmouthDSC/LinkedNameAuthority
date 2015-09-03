namespace :import do

  desc "Import faculty from Oracle."
  task oracle_faculty: :environment do
    import = Importer.new(title: 'HR-faculty', verbose: true, throw_errors: false, emails: 'carlamgalarza@gmail.com')
    Oracle::Faculty.find_each do |person|
      import.into_lna(person.to_hash)
    end
    import.send_email
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
