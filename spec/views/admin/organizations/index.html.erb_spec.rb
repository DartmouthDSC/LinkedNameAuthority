require 'rails_helper'

describe 'admin/organizations/index' do

	before(:context) do
		@t = {:template => 'admin/organizations/index'}
	end

	context 'Logged in user' do
		include_context 'Mock view user'
		include_context 'Mock search params'

		context 'Any user' do
			before(:example) do
				render(@t)
			end

			it 'Echos @page into Javascript' do
				expect(rendered).to match(/\(.*#{@params[:page]}.*\)/)
			end		

			it 'Renders pagniation controls' do
				expect(rendered).to render_template(:partial => 'shared/_controls')
			end		
		end
	end
end