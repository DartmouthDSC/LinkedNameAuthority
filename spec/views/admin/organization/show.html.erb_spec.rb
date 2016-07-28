require 'rails_helper'

describe 'admin/organization/show' do

	before(:context) do
		@t = {:template => 'admin/organization/show'}
	end

	context 'Logged in user' do
		include_context 'Mock view user'
		include_context 'Mock generic params'

		context 'Any user' do
			before(:example) do
				render(@t)
			end

			it 'Hides an edit form' do
				expect(rendered).not_to render_template(:partial => 'shared/modals/_edit_organization')
			end

			it 'Echos param[:id] into Javascript' do
				expect(rendered).to match(/\(.*"#{@params[:id]}".*\)/)
			end				
		end

		context 'Editor user' do
			before(:example) do
				allow(@user).to receive(:editor?).and_return(true)
				render(@t)
			end

			it 'Shows an edit form' do
				expect(rendered).to render_template(:partial => 'shared/modals/_edit_organization')
			end
			
		end	

		context 'Creator user' do
			before(:example) do
				allow(@user).to receive(:creator?).and_return(true)
				render(@t)
			end	

			it 'Shows an edit form' do
				expect(rendered).to render_template(:partial => 'shared/modals/_edit_organization')
			end		
		end					

		context 'Admin user' do
			before(:example) do
				allow(@user).to receive(:admin?).and_return(true)
				render(@t)
			end	

			it 'Shows an edit form' do
				expect(rendered).to render_template(:partial => 'shared/modals/_edit_organization')
			end
		end
		
	end
end