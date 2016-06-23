require 'rails_helper'
require 'symplectic/elements/publication'

RSpec.describe Symplectic::Elements::Publication do
  before :all do
     api_object = Nokogiri::XML(fixture('publication.xml')).elements.first.children[1]
     @publication = Symplectic::Elements::Publication.new(api_object)
     puts @publication.to_hash.to_s
  end
  
  describe '.new' do
    subject { @publication }
    
    its(:id)          { is_expected.to eq '142658' }
    its(:author_list) {
      is_expected.to eq ['Montfort, Nick', 'Baudoin, Patsy', 'Bell, John', 'Bogost, Ian',
                         'Douglass, Jeremy', 'Marino, Mark C', 'Mateas, M']
    }
    its(:publisher)   { is_expected.to eq 'MIT Press (MA)' }
    its(:date)        { is_expected.to eq '2014-5-9' }
    its(:title)       { is_expected.to eq '10 Print Chr$(205. 5+rnd(1)); : Goto 10' }
    its(:page_start)  { is_expected.to eq '1' }
    its(:page_end)    { is_expected.to eq '329' }
    its(:pages)       { is_expected.to eq '328' }
    its(:volume)      { is_expected.to eq '1' }
    its(:issue)       { is_expected.to eq '17' }
    its(:number)      { is_expected.to eq 'S' }
    its(:doi)         { is_expected.to eq 'http://dx.doi.org/10.1097/00000000-200607000-00004' }
    its(:subject)     { is_expected.to eq ['Computers'] }
    its(:journal)     { is_expected.to eq 'TEST JOURNAL' }
    its(:abstract)    { is_expected.to eq 'This book takes a single line of code -- the extremely concise BASIC program for the Commodore 64 inscribed in the title -- and uses it as a lens through which to consider the phenomenon of creative computing and the way computer programs ...' }    
  end

  describe '.to_hash' do
    subject { @publication.to_hash }

    # make sure it has the right number of keys\
    its(:size) { is_expected.to eq 15 }
    
    its([:id])          { is_expected.to eq '142658' }
    its([:author_list]) {
      is_expected.to eq ['Montfort, Nick', 'Baudoin, Patsy', 'Bell, John', 'Bogost, Ian',
                         'Douglass, Jeremy', 'Marino, Mark C', 'Mateas, M']
    }
    its([:publisher])   { is_expected.to eq 'MIT Press (MA)' }
    its([:date])        { is_expected.to eq '2014-5-9' }
    its([:title])       { is_expected.to eq '10 Print Chr$(205. 5+rnd(1)); : Goto 10' }
    its([:page_start])  { is_expected.to eq '1' }
    its([:page_end])    { is_expected.to eq '329' }
    its([:pages])       { is_expected.to eq '328' }
    its([:volume])      { is_expected.to eq '1' }
    its([:issue])       { is_expected.to eq '17' }
    its([:number])      { is_expected.to eq 'S' }
    its([:doi])         { is_expected.to eq 'http://dx.doi.org/10.1097/00000000-200607000-00004' }
    its([:subject])     { is_expected.to eq ['Computers'] }
    its([:journal])     { is_expected.to eq 'TEST JOURNAL' }
    its([:abstract])    { is_expected.to eq 'This book takes a single line of code -- the extremely concise BASIC program for the Commodore 64 inscribed in the title -- and uses it as a lens through which to consider the phenomenon of creative computing and the way computer programs ...' }  
  end  
end
