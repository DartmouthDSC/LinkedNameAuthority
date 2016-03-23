namespace :load do
  desc "Load from all feeds."
  task all: :environment do
    Load::Organization.from_hr
    Load::People.from_hr_faculty_view
    Load::Documents.from_elements
  end
end
