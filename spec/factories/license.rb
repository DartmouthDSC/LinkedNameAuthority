FactoryGirl.define do
  factory :unrestricted_access, class: Lna::Collection::FreeToRead do
    start_date 'January 15, 2025'
    end_date   'January 15, 2050'
    title      'Open Access Resolution'

    before(:create) do |license|
      unless license.document
        article = FactoryGirl.create(:article)
        article.free_to_read_refs << license
      end
    end 
  end

  factory :license, class: Lna::Collection::LicenseReference do
    start_date  'January 15, 2000'
    end_date    'January 15, 2025'
    title       'Creative Commons BY-NC-SA 3.0'
    license_uri 'https://creativecommons.org/licenses/by-nc-sa/3.0/'

    before(:create) do |license|
      unless license.document
        article = FactoryGirl.create(:article)
        article.license_refs << license
      end
    end
  end
end
