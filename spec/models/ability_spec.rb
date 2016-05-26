require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe "User abilities" do
    subject(:ability) { Ability.new(user) }

    let(:fedora_obj) { ActiveFedora::Base.new }
    let(:role)       { Role.new }
    let(:user)       { nil }
    
    context "when is an admin" do
      let(:admin) { Role.create(name: 'admin') }
      let(:user)  { FactoryGirl.create(:user, roles: [admin]) }
      
      it { is_expected.to be_able_to(:edit, role) }
      it { is_expected.to be_able_to(:show, role) }
      it { is_expected.to be_able_to(:add_user, role) }
      it { is_expected.to be_able_to(:remove_user, role) }
      it { is_expected.to be_able_to(:index, role) }
      it { is_expected.not_to be_able_to(:update, role) }
      it { is_expected.not_to be_able_to(:create, role) }
      it { is_expected.not_to be_able_to(:destroy, role) }
      it { is_expected.to be_able_to(:create, fedora_obj) }
      it { is_expected.to be_able_to(:update, fedora_obj) }
      it { is_expected.to be_able_to(:destroy, fedora_obj) }
    end

    context "when is an editor" do
      let(:editor) { Role.create(name: 'editor') }
      let(:user) { FactoryGirl.create(:user, roles: [editor]) }

      it { is_expected.not_to be_able_to(:edit, role) }
      it { is_expected.not_to be_able_to(:show, role) }
      it { is_expected.to be_able_to(:create, fedora_obj) }
      it { is_expected.to be_able_to(:update, fedora_obj) }
      it { is_expected.to be_able_to(:destroy, fedora_obj) }
    end
  end
end
