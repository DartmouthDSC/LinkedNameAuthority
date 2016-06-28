namespace :load do
  desc "Load from all feeds."
  task all: :environment do
    Load::Organizations.from_hr
    Load::People.from_hr
    Load::Documents.from_elements
  end

  desc "Load organization from hr view."
  task organizations: :environment do
    Load::Organizations.from_hr
  end

  desc "Load people from hr view."
  task people: :environment do
    Load::People.from_hr
  end

  desc "Load documents from Elements."
  task documents: :environment do
    Load::Documents.from_elements
  end
end
