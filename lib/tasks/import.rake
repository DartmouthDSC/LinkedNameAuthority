namespace :import do

  desc "Import faculty from Oracle."
  task oracle_faculty: :environment do
    require 'yaml'
    import = Importer.new(title: 'HR-faculty', verbose: true, throw_errors: false, emails: ENV['IMPORTER_EMAIL_NOTICES'])
    Oracle::Faculty.find_each do |person|
      import.into_lna(person.to_hash)
    end
    import.send_email
    puts "[#{Time.now}] Output from Faculty Load\n #{import.output.to_yaml}"
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
