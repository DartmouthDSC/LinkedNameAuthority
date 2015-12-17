FactoryGirl.define do
  factory :article, class: Lna::Collection::Document do
    author_list   'Doe, Jane'
    publisher     'New England Press'
    date          'January 15, 2000'
    title         'Car Emissions in New England'
    page_start    '14'
    page_end      '32'
    pages         '18'
    volume        '1'
    issue         '24'
    number        '3'
    canonical_uri ['http://example.com/newenglandpress/article/14']
    doi           'http://dx.doi.org/19.1409/ddlp.1490'
    abstract      'Lorem ipsum...'

    before(:create) do |document|
      unless document.collection
        jane = FactoryGirl.create(:jane)
        jane.collections.first.documents << document
      end
    end
  end

  factory :review, class: Lna::Collection::Document do
    author_list   'Smith, John'
    publisher     'Nature'
    date          'March 14, 2004'
    title         'Problematic Results for Car Emissions Studies'
    page_start    '13'
    page_end      '33'
    pages         '10'
    volume        '1'
    issue         '10'
    number        '2'
    canonical_uri ['http://example.com/nature/article/13']
    doi           'http://dx.doi.org/29.1093/dslp.1338'
    abstract      'Lorem ipsum...'
  end
end
