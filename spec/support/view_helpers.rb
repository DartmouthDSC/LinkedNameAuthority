shared_context 'Mock view user'  do
	before do
		@user = double("User").as_null_object
		allow(@user).to receive(:name).and_return('Username')
		allow(@user).to receive(:editor?).and_return(false)
		allow(@user).to receive(:creator?).and_return(false)
		allow(@user).to receive(:admin?).and_return(false)
		allow(@user).to receive(:viewer?).and_return(false)
		allow(controller).to receive(:current_user).and_return(@user)
	end
end

shared_context 'Mock generic params' do
	before do
		@params = {:id => '999999'}
		allow(controller).to (receive(:params).and_return(@params))
	end
end