namespace :import do

  desc "Import people (employees) from Oracle."
  task oracle_employee: :environment do
    Oracle::Employee.each do |person|
      Lna::Person.create_or_update(person.to_hash)
    end
  end

end
