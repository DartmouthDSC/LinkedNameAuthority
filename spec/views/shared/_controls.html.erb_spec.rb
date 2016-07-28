require 'rails_helper'

describe 'shared/_controls' do

	before(:context) do
		@t = {:template => 'shared/_controls'}
	end

	context 'Logged in user' do
		include_context 'Mock view user'
		include_context 'Mock search params'

		context 'Any user' do
			before(:example) do
				render(@t)
			end

			it 'Renders hidden pagniation fields' do
				expect(rendered).to include(hidden_field_tag('foaf:full_name', @params['foaf:full_name']))
			end						
		end
	end
end