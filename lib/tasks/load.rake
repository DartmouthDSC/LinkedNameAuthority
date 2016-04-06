namespace :load do
  desc "Load from all feeds."
  task all: :environment do
    Load::Organizations.from_hr
    Load::People.from_hr_faculty_view
    Load::Documents.from_elements
  end

  desc "Load organization from hr table."
  task organizations: :environment do
    Load::Organizations.from_hr
  end
end
