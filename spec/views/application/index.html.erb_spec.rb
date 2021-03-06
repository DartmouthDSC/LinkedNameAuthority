require 'rails_helper'

describe 'application/index' do

	before(:context) do
		@t = {:template => 'application/index', :layout => 'layouts/lna'}
	end

	it 'Shows login button to anonymous users' do
		render(:template => 'application/index', :layout => 'layouts/lna')

		expect(rendered).to include('Log In')
	end

	context 'Logged in user' do
		include_context 'Mock view user'

		context 'Any user' do
			before(:example) do
				render(@t)
			end

			it 'Shows logout button to logged in users' do
				expect(rendered).to match(/Log.*out/)
			end
			it 'Renders a search form' do
				expect(view).to render_template(:partial => 'shared/modals/_find_works')
			end
			it 'Hides an add form' do
				expect(rendered).not_to render_template(:partial => 'shared/modals/_new_work')
			end

			it 'Hides roles link from non-admin users' do
				expect(rendered).not_to include(role_management.roles_path)
			end				
		end

		context 'Editor user' do
			before(:example) do
				allow(@user).to receive(:editor?).and_return(true)
				render(@t)
			end

			it 'Hides roles link from editor users' do
				expect(rendered).not_to include(role_management.roles_path)
			end		
			it 'Hides an add form from editor users' do
				expect(rendered).not_to render_template(:partial => 'shared/modals/_new_work')
			end			
		end	

		context 'Creator user' do
			before(:example) do
				allow(@user).to receive(:creator?).and_return(true)
				render(@t)
			end

			it 'Hides roles link from creator users' do
				expect(rendered).not_to include(role_management.roles_path)
			end		
			it 'Shows an add form to creator users' do
				expect(rendered).to render_template(:partial => 'shared/modals/_new_work')
			end			
		end					

		context 'Admin user' do
			before(:example) do
				allow(@user).to receive(:admin?).and_return(true)
				render(@t)
			end

			it 'Shows roles link to admin users' do
				expect(rendered).to include(role_management.roles_path)
			end		
			it 'Shows an add form to admin users' do
				expect(rendered).to render_template(:partial => 'shared/modals/_new_work')
			end			
		end

	end
end