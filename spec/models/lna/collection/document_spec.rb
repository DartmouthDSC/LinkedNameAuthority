require 'rails_helper'

RSpec.describe Lna::Collection::Document, type: :model do
  it 'has valid factory' do
    article = FactoryGirl.create(:article)
    expect(article).to be_truthy
    id = article.collection.person.primary_org.id
    article.collection.person.destroy
    Lna::Organization.find(id).destroy
  end

  describe '.create' do
    before :context do
      @article = FactoryGirl.create(:article)
    end

    after :context do
      id = @article.collection.person.primary_org.id
      @article.collection.person.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @article }

    it { is_expected.to be_instance_of Lna::Collection::Document }
    it { is_expected.to be_a ActiveFedora::Base }
    
    it 'create id' do
      expect(subject.id).to be_truthy
    end

    it 'is persisted' do
      expect(subject.persisted?).to be_truthy
    end
    
    it 'sets author_list' do
      expect(subject.author_list).to eql 'Doe, Jane'
    end
    
    it 'sets publisher' do
      expect(subject.publisher).to eql 'New England Press'
    end
    
    it 'sets date' do
      expect(subject.date).to be_instance_of Date
      expect(subject.date.to_s).to eql '2000-01-15'
    end
    
    it 'sets title' do
      expect(subject.title).to eql 'Car Emissions in New England'
    end
    
    it 'sets page_start' do
      expect(subject.page_start).to eql '14'
    end
    
    it 'sets page_end' do
      expect(subject.page_end).to eql '32'
    end
    
    it 'pages' do
      expect(subject.pages).to eql '18'
    end
    
    it 'volume' do
      expect(subject.volume).to eql '1'
    end
    
    it 'issue' do
      expect(subject.issue).to eql '24'
    end
    
    it 'number' do
      expect(subject.number).to eql '3'
    end
    
    it 'canonical_uri' do
      expect(subject.canonical_uri).to eql ['http://example.com/newenglandpress/article/14']
    end
    
    it 'doi' do
      expect(subject.doi).to eql 'http://dx.doi.org/19.1409/ddlp.1490'
    end
  end

  describe '#reviews' do
    before :context do
      @article = FactoryGirl.create(:article)
      @review_one = FactoryGirl.create(:review, review_of: @article)
      @article.save
    end

    after :context do
      id = @article.collection.person.primary_org.id
      @article.collection.person.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @article }
    
    it 'can have one review' do
      expect(subject.reviews.size).to be 1
      expect(subject.reviews.first).to eq @review_one
    end
    
    it 'review_of is set in other document' do
      expect(@review_one.review_of).to eq subject
    end
    
    it 'can have multiple reviews' do
      review_two = FactoryGirl.create(:review, review_of: subject)
      subject.reload
      expect(subject.reviews.size).to be 2
      expect(subject.reviews).to include review_two
    end
  end

  describe '#review_of' do
    before :context do
      @article = FactoryGirl.create(:article)
      @review = FactoryGirl.create(:review, review_of: @article)
    end

    after :context do
      id = @article.collection.person.primary_org.id
      @article.collection.person.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @article }
    
    it 'can be a review of another document' do
      expect(@review.review_of).to eql subject
      expect(subject.reviews).to include @review
    end

    it 'cannot be a review cannot be part of a collection' do
      @review.collection = @article.collection
      expect(@review.save).to be false
    end
  end

  describe '#collection' do
    before :example do
      @article = FactoryGirl.create(:article)
    end

    after :example do
      id = @article.collection.person.primary_org.id
      @article.collection.person.destroy
      Lna::Organization.find(id).destroy
    end
    
    it 'is part of a collection' do
      expect(@article.collection).to be_instance_of Lna::Collection
    end
  end
  
  describe 'validations' do
    before :example do
      @article = FactoryGirl.create(:article)
    end

    after :example do
      @article.reload
      id = @article.collection.person.primary_org.id
      @article.collection.person.destroy
      Lna::Organization.find(id).destroy
    end

    subject { @article }
    
    it 'assures title is set' do
      subject.title = nil
      expect(subject.save).to be false
    end
    
    it 'assures author_list is set' do
      subject.author_list = nil
      expect(subject.save).to be false
    end

    it 'assures that a document is part of a collection or a review' do
      subject.collection = nil
      expect(subject.save).to be false
    end

    it 'assures that a document is not both part of a collection and a review of' do
      review_of = FactoryGirl.build(:review)
      subject.review_of = review_of
      expect(subject.save).to be false
    end
  end
end
