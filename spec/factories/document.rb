FactoryGirl.define do
  factory :document, class: Lna::Collection::Document do
    author_list   'Jane Doe'
    publisher     'New England Press'
    date          'January 15, 2000'
    title         'Car Emissions in New England'
    page_start    '14'
    page_end      '32'
    pages         '18'
    volume        '1'
    issue         '24'
    number        '3'
    canonical_uri 'http://example.com/newenglandpress/article/14'
    doi           'http://dx.doi.org/19.1409/ddlp.1490'

    before(:create) do |document|
      jane = FactoryGirl.create(:jane)
      jane.collections.first.documents << document
    end
  end
end
